/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

import InfomaniakDI
import STResources
import SwiftUI

struct PreviewThumbnailProvider: ThumbnailProvidable {
    func generateThumbnailFor(fileUUID: String, transferUUID: String, fileURL: URL?, scale: CGFloat) async -> Image? {
        return STResourcesAsset.Images.boxes.swiftUIImage
    }

    func generateThumbnail(fileURL: URL, scale: CGFloat) async throws -> Image {
        return STResourcesAsset.Images.boxes.swiftUIImage
    }

    func generateThumbnailFor(url fileURL: URL, scale: CGFloat, destinationURL: URL) async throws {}

    func generateTemporaryThumbnailsFor(uploadSession: SendableUploadSession, scale: CGFloat) async -> [(String, URL)] {
        return []
    }

    func moveTemporaryThumbnails(uuidsWithThumbnail: [(String, URL)], transferUUID: String) {}
}

public struct PreviewThumbnailProvider_TargetAssembly {
    public init() {
        SimpleResolver.sharedResolver.store(factory: Factory(type: ThumbnailProvidable.self) { _, _ in
            PreviewThumbnailProvider()
        })
    }
}
