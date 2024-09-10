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

class DisplayableFile: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DisplayableFile, rhs: DisplayableFile) -> Bool {
        lhs.id == rhs.id && lhs.children == rhs.children
    }

    let id: String

    let name: String
    let isFolder: Bool

    var children = [DisplayableFile]()
    var parent: DisplayableFile?

    // Real Files property
    var url: URL? = nil
    private var size: Int64 = 0
    var mimeType = ""

    init(name: String, isFolder: Bool) {
        id = UUID().uuidString
        self.name = name
        self.isFolder = isFolder
    }

    init(id: String, name: String, url: URL, size: Int64, mimeType: String) {
        self.id = id
        self.name = name
        self.url = url
        self.size = size
        self.mimeType = mimeType
        isFolder = false
    }

    var computedSize: Int64 {
        if isFolder {
            return children.map { $0.computedSize }.reduce(0, +)
        }
        return size
    }

    /// Return all file children in the tree (no folder)
    var computedChildren: [DisplayableFile] {
        var array = [DisplayableFile]()
        if isFolder {
            for element in children {
                array.append(contentsOf: element.computedChildren)
            }
        } else {
            array.append(self)
        }
        return array
    }
}

struct UploadFile: Identifiable {
    var id: String {
        return url.absoluteString
    }

    let url: URL
    let size: Int64
    var path: String

    init?(url: URL) {
        guard let resources = try? url.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey, .nameKey]),
              let isDirectory = resources.isDirectory, !isDirectory else { return nil }

        self.url = url
        path = resources.name ?? url.lastPathComponent
        size = Int64(resources.fileSize ?? 0)
    }

    var mimeType: String {
        url.typeIdentifier ?? ""
    }
}

@MainActor
class NewTransferManager: ObservableObject {
    @Published var uploadFiles = [UploadFile]()
    @Published var displayableFiles = [DisplayableFile]()

    init() {
        cleanTmpDir()
    }

    func addFiles(urls: [URL]) {
        do {
            let tmpUrls = moveToTmp(files: urls)

            try uploadFiles.append(contentsOf: flatten(urls: tmpUrls))

            prepareForDisplay()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

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

        file.parent?.children.removeAll { $0.id == file.id }
        cleanEmptyFolders(fromFile: file)
    }
}

extension NewTransferManager {
//    private func moveToPermanent(containerUuid: String, files: [URL]) -> [URL] {
//        for uploadFile in uploadFiles {}
//    }

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

    private func cleanTmpDir() {
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

    private func cleanEmptyFolders(fromFile file: DisplayableFile) {
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

// MARK: - Flattening

extension NewTransferManager {
    /// Flatten folder + set path
    private func flatten(urls: [URL]) throws -> [UploadFile] {
        let resourceKeys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey, .nameKey]
        var result = [UploadFile]()

        for url in urls {
            guard let resources = try? url.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey, .nameKey]),
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

    private func prepareForDisplay() {
        var tree = [DisplayableFile]()
        for file in uploadFiles {
            var pathComponents = file.path.components(separatedBy: "/")
            let fileName = pathComponents.removeLast()

            let displayableFile = DisplayableFile(
                id: file.id,
                name: fileName,
                url: file.url,
                size: file.size,
                mimeType: file.mimeType
            )

            if let parent = findFolder(forPath: pathComponents, in: &tree) {
                displayableFile.parent = parent
                parent.children.append(displayableFile)
            } else {
                tree.append(displayableFile)
            }
        }

        displayableFiles = tree
    }

    private func findFolder(forPath pathComponents: [String], in tree: inout [DisplayableFile]) -> DisplayableFile? {
        guard !pathComponents.isEmpty else {
            // For initial call
            return nil
        }

        var result: DisplayableFile
        var path = pathComponents
        let currentName = path.removeFirst()

        if let branch = tree.first(where: {
            $0.name == currentName && $0.isFolder
        }) {
            result = branch
        } else {
            result = DisplayableFile(name: currentName, isFolder: true)
            tree.append(result)
        }

        if !path.isEmpty {
            return findFolderRecursively(forPath: path, in: result)
        } else {
            return result
        }
    }

    private func findFolderRecursively(forPath pathComponents: [String], in parent: DisplayableFile) -> DisplayableFile? {
        var result: DisplayableFile
        var path = pathComponents
        let currentName = path.removeFirst()

        if let branch = parent.children.first(where: {
            $0.name == currentName && $0.isFolder
        }) {
            result = branch
        } else {
            result = DisplayableFile(name: currentName, isFolder: true)
            result.parent = parent
            parent.children.append(result)
        }

        if !path.isEmpty {
            return findFolderRecursively(forPath: path, in: result)
        } else {
            return result
        }
    }
}
