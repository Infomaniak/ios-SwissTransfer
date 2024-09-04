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

    init(url: URL, size: Int64) {
        self.url = url
        self.size = size
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

            for tmpUrl in tmpUrls {
                let attributes = try FileManager.default.attributesOfItem(atPath: tmpUrl.path())
                let size = attributes[.size] as? Int64

                let uploadFile = UploadFile(
                    url: tmpUrl,
                    size: size ?? 0
                )
                uploadFiles.append(uploadFile)
            }
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
