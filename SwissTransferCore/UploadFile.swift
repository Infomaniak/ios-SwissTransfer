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
import OSLog
import STCore
import UniformTypeIdentifiers

public final class UploadFile: Identifiable, Sendable {
    public var id: String {
        return url.absoluteString
    }

    public let url: URL
    public let size: Int64
    public let path: String?
    public let mimeType: String

    public init?(url: URL) {
        guard let resources = try? url.resourceValues(forKeys: [
            .fileSizeKey,
            .isDirectoryKey,
            .nameKey
        ]), resources.isDirectory == false else { return nil }

        self.url = url
        size = Int64(resources.fileSize ?? 0)
        if let typeIdentifier = url.typeIdentifier,
           let mimeType = UTType(typeIdentifier)?.preferredMIMEType {
            self.mimeType = mimeType
        } else {
            mimeType = ""
        }

        do {
            let baseURL = try URL.tmpUploadDirectory()
            var newPath = url.deletingLastPathComponent().path().trimmingPrefix(baseURL.path())
            if newPath.hasSuffix("/") {
                _ = newPath.removeLast()
            }

            if newPath.isEmpty {
                path = nil
            } else {
                path = String(newPath)
            }

        } catch {
            Logger.general.error("Error while constructing file path: \(url) \(error.localizedDescription)")
            return nil
        }
    }
}

extension UploadFile: UploadFileSession {
    public var localPath: String {
        url.absoluteString
    }

    public var name: String {
        url.lastPathComponent
    }

    public var remoteUploadFile: (any RemoteUploadFile)? {
        nil
    }
}
