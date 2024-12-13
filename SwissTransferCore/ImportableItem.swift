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
import PhotosUI
import SwiftUI
import UIKit

public struct ImportedItem: Identifiable, Equatable, Hashable, Sendable {
    public var id: Int {
        item.hashValue
    }

    let item: any ImportableItem

    public init(item: any ImportableItem) {
        self.item = item
    }

    public func importItem() async throws -> URL {
        let url = try await item.importItem()
        return url
    }

    public static func == (lhs: ImportedItem, rhs: ImportedItem) -> Bool {
        lhs.item.hashValue == rhs.item.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(item.hashValue)
    }
}

public protocol ImportableItem: Equatable, Hashable, Sendable {
    func importItem() async throws -> URL
}

extension PhotosPickerItem: ImportableItem {
    enum ErrorDomain: Error {
        case assetImportFailed
    }

    public func importItem() async throws -> URL {
        guard let photoFile = try await loadTransferable(type: PhotoLibraryContent.self) else {
            throw ErrorDomain.assetImportFailed
        }

        return photoFile.url
    }
}

extension UIImage: ImportableItem {
    public func importItem() async throws -> URL {
        let fileName = URL.defaultFileName()
        let url = try URL.tmpCacheDirectory().appendingPathComponent(fileName).appendingPathExtension(for: UTType.png)
        try pngData()?.write(to: url)

        return url
    }
}

extension URL: ImportableItem {
    public func importItem() async throws -> URL {
        return self
    }
}
