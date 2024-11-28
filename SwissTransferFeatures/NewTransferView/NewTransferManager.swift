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
import STCore
import SwiftUI
import SwissTransferCore

enum TmpDirType: String {
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
public class NewTransferManager: ObservableObject {
    public init() {
        cleanTmpDir(type: .upload)
    }

    deinit {
        cleanTmpDir(type: .all)
    }

    /// Add files to Upload Folder
    /// Return the content of the folder
    public func addFiles(urls: [URL]) -> [DisplayableFile] {
        moveToTmp(files: urls)
        cleanTmpDir(type: .cache)
        return filesAt(folderURL: nil)
    }

    /// Removes completely the given file and his children from :
    /// - FileManager
    /// - Upload list
    /// - Displayable list
    public func remove(file: DisplayableFile, completion: () -> Void) {
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
        for file in files {
            do {
                let destination = try destinationURLFor(source: file)
                _ = file.startAccessingSecurityScopedResource()
                try FileManager.default.copyItem(at: file, to: destination)
            } catch {
                Logger.general.error("An error occured while copying files: \(error)")
            }
            file.stopAccessingSecurityScopedResource()
        }
    }

    /// Find a valid name if a file/folder already exist with the same name
    func destinationURLFor(source: URL) throws -> URL {
        let allFiles = try FileManager.default.contentsOfDirectory(at: URL.tmpUploadDirectory(), includingPropertiesForKeys: nil)
            .map(\.lastPathComponent)

        let shortName = source.deletingPathExtension().lastPathComponent
        var increment = 0
        var testName = source.lastPathComponent
        while allFiles.contains(where: { $0 == testName }) {
            increment += 1
            testName = shortName.appending("(\(increment))")
            if !source.pathExtension.isEmpty {
                testName.append(".\(source.pathExtension)")
            }
        }
        return try URL.tmpUploadDirectory().appending(path: testName)
    }

    /// Empty the temporary directory
    nonisolated func cleanTmpDir(type: TmpDirType) {
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
    func filesToUpload() throws -> [UploadFile] {
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

    func filesAt(folderURL: URL?) -> [DisplayableFile] {
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
