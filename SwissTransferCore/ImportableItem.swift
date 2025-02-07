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

extension NSItemProvider: @unchecked @retroactive Sendable, ImportableItem {
    enum ErrorDomain: Error {
        /// Not matching an UTI
        case UTINotFound

        /// The type needs dedicated handling
        case unsupportedUnderlyingType

        /// The item cannot be saved to a file
        case notWritableItem
    }

    public func importItem() async throws -> URL {
        switch underlyingType {
        case .isURL:
            let getURL = try ItemProviderURLRepresentation(from: self)
            let result = try await getURL.result.get()
            return result.url

        case .isText:
            let getText = try ItemProviderTextRepresentation(from: self)
            let resultURL = try await getText.result.get()
            return resultURL

        case .isImageData, .isCompressedData, .isMiscellaneous:
            let getFile = try ItemProviderFileRepresentation(from: self)
            let result = try await getFile.result.get()
            return result.url

        case .isDirectory:
            let getFile = try ItemProviderZipRepresentation(from: self)
            let result = try await getFile.result.get()
            return result.url

        case .isPropertyList:
            throw ErrorDomain.notWritableItem

        case .none:
            throw ErrorDomain.UTINotFound

        // Keep it for forward compatibility
        default:
            throw ErrorDomain.unsupportedUnderlyingType
        }
    }
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
        let url = try URL.tmpCacheDirectory().appendingPathComponent(fileName).appendingPathExtension(for: UTType.jpeg)
        try jpegData(compressionQuality: 0.8)?.write(to: url)

        return url
    }
}

extension URL: ImportableItem {
    public func importItem() async throws -> URL {
        return self
    }
}
