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
import STCore
import UniformTypeIdentifiers

public class TransferableFile: Hashable, DisplayableFile {
    public var uid: String {
        localURL.path()
    }

    public let fileName: String
    public let fileSize: Int64
    public let localURL: URL
    public let mimeType: String?
    public let isFolder: Bool
    public let addedDate: Date

    public func localURLFor(transferUUID: String) -> URL? {
        localURL
    }

    public init?(url: URL) {
        guard let resources = try? url.resourceValues(forKeys: [
            .isDirectoryKey,
            .nameKey,
            .addedToDirectoryDateKey
        ]) else { return nil }

        localURL = url
        fileName = url.lastPathComponent
        isFolder = resources.isDirectory ?? false
        fileSize = Int64(url.size())
        mimeType = UTType(url.typeIdentifier ?? "")?.preferredMIMEType
        addedDate = resources.addedToDirectoryDate ?? .now
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: TransferableFile, rhs: TransferableFile) -> Bool {
        lhs.id == rhs.id
    }
}

public struct TransferableRootFolder: Identifiable, Hashable {
    public let id = UUID()

    public init() {}
}
