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
import SwiftUI
import SwissTransferCore

@MainActor
class NewTransferManager: ObservableObject {
    @Published var uploadFiles = [UploadFile]()
    @Published var displayableFiles = [DisplayableFile]()

    init() {
        cleanTmpDir()
    }

    deinit {
        cleanTmpDir()
    }

    func addFiles(urls: [URL]) {
        do {
            let tmpUrls = moveToTmp(files: urls)

            try uploadFiles.append(contentsOf: flatten(urls: tmpUrls))

            displayableFiles = prepareForDisplay()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    /// Removes completely the given file and his children from :
    /// - FileManager
    /// - Upload list
    /// - Displayable list
    func remove(file: DisplayableFile) {
        let filesToRemove = file.computedChildren

        for fileToRemove in filesToRemove {
            uploadFiles.removeAll { $0.id == fileToRemove.id }
            guard let url = fileToRemove.url else { continue }
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
        }

        removeFileAndCleanFolders(file: file)
    }
}

extension NewTransferManager {
//    private func moveToPermanent(containerUuid: String, files: [URL]) -> [URL] {
//        for uploadFile in uploadFiles {}
//    }

    /// Move the imported files/folder in the temporary directory
    private func moveToTmp(files: [URL]) -> [URL] {
        var urls = [URL]()
        let tmpDirectory = FileManager.default.temporaryDirectory

        do {
            for file in files {
                let destination = tmpDirectory.appending(path: file.lastPathComponent)
                try FileManager.default.copyItem(at: file, to: destination)
                urls.append(destination)
            }
        } catch {
            print("Error moving file: \(error.localizedDescription)")
        }

        return urls
    }

    /// Empty the temporary directory
    private nonisolated func cleanTmpDir() {
        do {
            let tmp = FileManager.default.temporaryDirectory

            let childrens = try FileManager.default.contentsOfDirectory(
                at: tmp,
                includingPropertiesForKeys: nil,
                options: .skipsSubdirectoryDescendants
            )

            for children in childrens {
                try FileManager.default.removeItem(at: children)
            }
        } catch {
            print("Error cleaning tmp directory: \(error.localizedDescription)")
        }
    }

    /// Remove the given file from his parent
    /// Start from the file and remove all folders above him who doesn't contain any real file
    private func removeFileAndCleanFolders(file: DisplayableFile) {
        file.parent?.children.removeAll { $0.id == file.id }

        guard let parent = file.parent else {
            displayableFiles.removeAll { $0.id == file.id }
            return
        }

        var currentFile: DisplayableFile = parent
        while currentFile.computedChildren.isEmpty {
            guard let parent = currentFile.parent else {
                // Base of the tree
                displayableFiles.removeAll { $0.id == currentFile.id }
                break
            }
            parent.children.removeAll { $0.id == currentFile.id }
            currentFile = parent
        }
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
        let fakeFirstParent = DisplayableFile(name: "", isFolder: true)
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
                let newFolder = DisplayableFile(name: currentName, isFolder: true)
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
