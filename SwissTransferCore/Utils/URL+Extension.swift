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
import InfomaniakDI

public extension URL {
    /// URL to store files
    /// Files are stored in the cache directory so they can be removed by the system if it need more storage
    static func fileStorageFolder(fileUUID: String) throws -> URL {
        @InjectService var pathProvider: AppGroupPathProvidable
        let targetFolderURL = pathProvider.cacheDirectoryURL
            .appendingPathComponent("files", isDirectory: true)
            .appendingPathComponent(fileUUID, isDirectory: true)
        try FileManager.default.createDirectory(at: targetFolderURL, withIntermediateDirectories: true)
        return targetFolderURL
    }

    /// URL to store previews
    /// Previews are stored in the group directory
    static func previewStorageFolder(fileUUID: String) throws -> URL {
        @InjectService var pathProvider: AppGroupPathProvidable
        let targetFolderURL = pathProvider.groupDirectoryURL
            .appendingPathComponent("previews", isDirectory: true)
            .appendingPathComponent(fileUUID, isDirectory: true)
        try FileManager.default.createDirectory(at: targetFolderURL, withIntermediateDirectories: true)
        return targetFolderURL
    }

    static func tmpUploadDirectory() throws -> URL {
        let tmpDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("upload", isDirectory: true)
        try FileManager.default.createDirectory(at: tmpDirectory, withIntermediateDirectories: true)
        return tmpDirectory
    }

    static func tmpCacheDirectory() throws -> URL {
        let tmpDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("cache", isDirectory: true)
        try FileManager.default.createDirectory(at: tmpDirectory, withIntermediateDirectories: true)
        return tmpDirectory
    }

    /// Size of the file/folder in bytes
    func size() -> Int {
        guard let resources = try? resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey]) else { return 0 }

        if resources.isDirectory == true {
            return folderSize() ?? 0
        } else {
            return resources.fileSize ?? 0
        }
    }

    private func folderSize() -> Int? {
        guard let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: [.fileSizeKey])
        else { return nil }
        var size = 0
        for case let fileURL as URL in enumerator {
            guard let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                continue
            }
            size += fileSize
        }
        return size
    }
}
