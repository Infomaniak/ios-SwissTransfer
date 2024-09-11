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

public struct UploadFile: Identifiable {
    public var id: String {
        return url.absoluteString
    }

    public let url: URL
    public let size: Int64
    public var path: String

    public init?(url: URL) {
        guard let resources = try? url.resourceValues(forKeys: [
            .fileSizeKey,
            .isDirectoryKey,
            .nameKey
        ]),
            let isDirectory = resources.isDirectory, !isDirectory else { return nil }

        self.url = url
        path = resources.name ?? url.lastPathComponent
        size = Int64(resources.fileSize ?? 0)
    }

    var mimeType: String {
        url.typeIdentifier ?? ""
    }
}
