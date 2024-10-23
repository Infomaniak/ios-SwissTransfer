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

public class DisplayableFile: Identifiable, Hashable {
    public var id: String {
        url.path()
    }

    public let name: String
    public let isFolder: Bool

    public var url: URL
    public var size: Int64 = 0
    public var mimeType = ""

    public init?(url: URL) {
        guard let resources = try? url.resourceValues(forKeys: [
            .isDirectoryKey,
            .nameKey
        ]) else { return nil }

        self.url = url
        name = url.lastPathComponent
        isFolder = resources.isDirectory ?? false
        size = Int64(url.size())
        mimeType = url.typeIdentifier ?? ""
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DisplayableFile, rhs: DisplayableFile) -> Bool {
        lhs.id == rhs.id
    }
}

public struct DisplayableRootFolder: Identifiable, Hashable {
    public let id = UUID()

    public init() {}
}
