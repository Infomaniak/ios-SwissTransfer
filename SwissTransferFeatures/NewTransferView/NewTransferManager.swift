/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2024 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
import InfomaniakCore
import OSLog
import SwiftUI
import SwissTransferCore

private enum TmpDirType: String {
    case all
    case cache
    case upload

    var directory: URL {
        get throws {
            switch self {
            case .all:
                return FileManager.default.temporaryDirectory
            case .cache:
                return try URL.tmpCacheDirectory()
            case .upload:
                return try URL.tmpUploadDirectory()
            }
        }
    }
}

@MainActor
class NewTransferManager: ObservableObject {
    private var uploadFiles = [UploadFile]()
    @Published var displayableFiles = [DisplayableFile]()
    @Published var transferType: TransferType = .qrcode

    init(urls: [URL]) {
        cleanTmpDir(type: .upload)
        addFiles(urls: urls)
        cleanTmpDir(type: .cache)
    }

    deinit {
        cleanTmpDir(type: .all)
    }

    func addFiles(urls: [URL]) {
        do {
            let tmpUrls = moveToTmp(files: urls)

            try uploadFiles.append(contentsOf: flatten(urls: tmpUrls))

            displayableFiles = prepareForDisplay()
        } catch {
            Logger.general.error("An error occured while flattening files: \(error)")
        }
    }

    /// Removes completely the given file and his children from :
    /// - FileManager
    /// - Upload list
    /// - Displayable list
    func remove(file: DisplayableFile) async {
        let filesToRemove = await file.computedChildren()

        for fileToRemove in filesToRemove {
            uploadFiles.removeAll { $0.id == fileToRemove.id }
            guard let url = fileToRemove.url else { continue }
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                Logger.general.error("An error occured while removing file: \(error)")
            }
        }

        await removeFileAndCleanFolders(file: file)
    }
}

extension NewTransferManager {
    /// Move the imported files/folder in the temporary directory
    private func moveToTmp(files: [URL]) -> [URL] {
        var urls = [URL]()

        do {
            let tmpDirectory = try URL.tmpUploadDirectory()
            for file in files {
                let destination = tmpDirectory.appending(path: file.lastPathComponent)
                _ = file.startAccessingSecurityScopedResource()
                try FileManager.default.copyItem(at: file, to: destination)
                file.stopAccessingSecurityScopedResource()
                urls.append(destination)
            }
        } catch {
            Logger.general.error("An error occured while moving files to temporary directory: \(error)")
        }

        return urls
    }

    /// Empty the temporary directory
    private nonisolated func cleanTmpDir(type: TmpDirType) {
        do {
            let tmp = try type.directory
            let children = try FileManager.default.contentsOfDirectory(
                at: tmp,
                includingPropertiesForKeys: nil,
                options: .skipsSubdirectoryDescendants
            )

            for child in children {
                try FileManager.default.removeItem(at: child)
            }
        } catch {
            Logger.general.error("An error occurred while cleaning temporary directory: \(type.rawValue) \(error)")
        }
    }

    /// Remove the given file from his parent
    /// Start from the file and remove all folders above him who doesn't contain any real file
    private func removeFileAndCleanFolders(file: DisplayableFile) async {
        file.parent?.children.removeAll { $0.id == file.id }

        guard let parent = file.parent else {
            displayableFiles.removeAll { $0.id == file.id }
            return
        }

        var currentFile: DisplayableFile = parent
        while await currentFile.computedChildren().isEmpty {
            guard let parent = currentFile.parent else {
                // Base of the tree
                displayableFiles.removeAll { $0.id == currentFile.id }
                break
            }
            parent.children.removeAll { $0.id == currentFile.id }
            currentFile = parent
        }

        objectWillChange.send()
    }
}

// MARK: - Tools

extension NewTransferManager {
    /// Flatten folder + set path
    /// Take the list of the imported URLs
    /// Flatten the folders of these URLs to get only the File inside them and create a short path for each file
    /// Then return all the found Files to upload
    /// - Parameters:
    ///   - urls: List of imported URLs
    /// - Returns: An array of file to Upload (no folder, only file)
    private func flatten(urls: [URL]) throws -> [UploadFile] {
        let resourceKeys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey, .nameKey]
        var result = [UploadFile]()

        for url in urls {
            guard let resources = try? url.resourceValues(forKeys: Set(resourceKeys)),
                  let isDirectory = resources.isDirectory else { continue }

            if isDirectory {
                let folderEnumerator = FileManager.default.enumerator(
                    at: url,
                    includingPropertiesForKeys: resourceKeys,
                    options: .skipsHiddenFiles
                )
                while case let element as URL = folderEnumerator?.nextObject() {
                    guard var uploadFile = UploadFile(url: element) else { continue }

                    let urlToTrim = url.deletingLastPathComponent()
                    let newPath = uploadFile.url.path().trimmingPrefix(urlToTrim.path())
                    uploadFile.path = String(newPath)

                    uploadFiles.append(uploadFile)
                }
            } else {
                guard let uploadFile = UploadFile(url: url) else { continue }
                result.append(uploadFile)
            }
        }

        return result
    }

    /// Take the files in uploadFiles and create a tree using fake folders
    /// - Returns: The created tree
    private func prepareForDisplay() -> [DisplayableFile] {
        var tree = [DisplayableFile]()
        for file in uploadFiles {
            let displayableFile = DisplayableFile(uploadFile: file)
            let pathComponents = file.path.components(separatedBy: "/")

            if let parent = findFolder(forPath: pathComponents, in: &tree) {
                displayableFile.parent = parent
                parent.children.append(displayableFile)
            } else {
                tree.append(displayableFile)
            }
        }

        return tree
    }

    /// Give the folder in which we need to put the file with the given path
    /// - Parameters:
    ///   - pathComponents: The path of the file (ex: ["parent", "child", "doc.txt"])
    ///   - tree: The tree in which we want
    /// to put the file (displayableFiles)
    /// - Returns: Return the folder
    private func findFolder(forPath pathComponents: [String], in tree: inout [DisplayableFile]) -> DisplayableFile? {
        var path = pathComponents.dropLast() // Remove the fileName from the path
        var result: DisplayableFile?

        // Used to simulate the base of the tree
        let fakeFirstParent = DisplayableFile(folderName: "")
        fakeFirstParent.children = tree
        var currentParent = fakeFirstParent

        while !path.isEmpty {
            let currentName = path.removeFirst()

            // Look for the current component in the children of the current parent
            if let branch = currentParent.children.first(where: {
                $0.name == currentName && $0.isFolder
            }) {
                result = branch
            } else {
                // If not found, create a new folder with the current component name
                let newFolder = DisplayableFile(folderName: currentName)
                newFolder.parent = currentParent
                currentParent.children.append(newFolder)

                result = newFolder
            }

            // Update the current parent to the folder we found/created
            currentParent = result!
        }

        // Reassign the fake parent children to the tree and remove the fake parent link from the elements of the tree base
        tree = fakeFirstParent.children
        for baseChild in tree {
            baseChild.parent = nil
        }

        return result
    }
}
