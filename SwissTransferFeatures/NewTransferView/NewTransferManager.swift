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
    @Published var transferType: TransferType = .qrcode

    init() {
        cleanTmpDir(type: .upload)
    }

    deinit {
        cleanTmpDir(type: .all)
    }

    /// Add files to Upload Folder
    /// Return the content of the folder
    func addFiles(urls: [URL]) -> [DisplayableFile] {
        moveToTmp(files: urls)
        cleanTmpDir(type: .cache)
        return filesAt(folderURL: nil)
    }

    /// Removes completely the given file and his children from :
    /// - FileManager
    /// - Upload list
    /// - Displayable list
    func remove(file: DisplayableFile, completion: () -> Void) {
        do {
            try FileManager.default.removeItem(at: file.url)
            cleanEmptyParent(of: file.url)
            completion()
        } catch {
            Logger.general.error("An error occured while removing file: \(error)")
        }
    }
}

extension NewTransferManager {
    /// Move the imported files/folder in the temporary directory
    private func moveToTmp(files: [URL]) {
        do {
            let tmpDirectory = try URL.tmpUploadDirectory()
            for file in files {
                do {
                    let destination = tmpDirectory.appending(path: file.lastPathComponent)
                    _ = file.startAccessingSecurityScopedResource()
                    try FileManager.default.copyItem(at: file, to: destination)
                } catch {
                    Logger.general.error("An error occured while copying files: \(error)")
                }
                file.stopAccessingSecurityScopedResource()
            }
        } catch {
            Logger.general.error("An error occured while moving files to temporary directory: \(error)")
        }
    }

    /// Empty the temporary directory
    private nonisolated func cleanTmpDir(type: TmpDirType) {
        do {
            try FileManager.default.removeItem(at: type.directory)
        } catch {
            Logger.general.error("An error occurred while cleaning temporary directory: \(type.rawValue) \(error)")
        }
    }

    private func cleanEmptyParent(of url: URL) {
        let parent = url.deletingLastPathComponent()
        do {
            let children = try FileManager.default.contentsOfDirectory(atPath: parent.path())
            guard children.isEmpty else { return }
            try FileManager.default.removeItem(at: parent)
            cleanEmptyParent(of: parent)
        } catch {
            Logger.general.error("An error occurred while cleaning parent folder of: \(url.path()) \(error)")
        }
    }
}

// MARK: - Tools

extension NewTransferManager {
    /// Flatten the upload folder
    /// Then return all the found Files to upload
    /// - Returns: An array of file to Upload (no folder, only file)
    public func filesToUpload() throws -> [UploadFile] {
        let resourceKeys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey, .nameKey]
        var result = [UploadFile]()

        let folderEnumerator = try FileManager.default.enumerator(
            at: URL.tmpUploadDirectory(),
            includingPropertiesForKeys: resourceKeys,
            options: .skipsHiddenFiles
        )
        while case let element as URL = folderEnumerator?.nextObject() {
            guard let uploadFile = UploadFile(url: element) else { continue }
            result.append(uploadFile)
        }

        return result
    }

    public func filesAt(folderURL: URL?) -> [DisplayableFile] {
        let resourceKeys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey, .nameKey]

        do {
            var src = try URL.tmpUploadDirectory()
            if let folderURL {
                src = folderURL
            }
            let urls = try FileManager.default.contentsOfDirectory(at: src, includingPropertiesForKeys: resourceKeys)

            let files = urls.compactMap { DisplayableFile(url: $0) }

            return files
        } catch {
            Logger.general.error("An error occurred while getting files from: \(folderURL?.path() ?? "") \(error)")
        }
        return []
    }
}
