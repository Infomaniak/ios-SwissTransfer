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
    public let id: String
    public let name: String
    public let isFolder: Bool

    // TODO: - Use SET ? To simplify all remove functions
    public var children = [DisplayableFile]()
    public var parent: DisplayableFile?

    // Real Files property
    public var url: URL? = nil
    private var size: Int64 = 0
    public var mimeType = ""

    public init(name: String, isFolder: Bool) {
        id = UUID().uuidString
        self.name = name
        self.isFolder = isFolder
    }

    public init(uploadFile: UploadFile) {
        id = uploadFile.id
        name = uploadFile.url.lastPathComponent
        url = uploadFile.url
        size = uploadFile.size
        mimeType = uploadFile.mimeType
        isFolder = false
    }

    public var computedSize: Int64 {
        if isFolder {
            return children.map { $0.computedSize }.reduce(0, +)
        }
        return size
    }

    /// Return all file children in the tree (no folder)
    public var computedChildren: [DisplayableFile] {
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DisplayableFile, rhs: DisplayableFile) -> Bool {
        lhs.id == rhs.id && lhs.children == rhs.children
    }
}
