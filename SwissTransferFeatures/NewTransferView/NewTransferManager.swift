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

class NewTransferManager: ObservableObject {
    @Published var uploadFiles = [UploadFile]()

    init() {
        cleanTmpDir()
    }

    func addFiles(urls: [URL]) {
        do {
            let tmpUrls = moveToTmp(files: urls)

            try uploadFiles.append(contentsOf: flatten(urls: tmpUrls))

            print(uploadFiles)
            // Create unflatten version

        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func remove(file: UploadFile) {
        do {
            try FileManager.default.removeItem(at: file.url)
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
        uploadFiles.removeAll { $0.id == file.id }
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

                    let newPath = uploadFile.url.path().trimmingPrefix(url.path())
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
}
