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

import OSLog
import QuickLookThumbnailing
import SwiftUI

public enum ThumbnailGenerator {
    public static func generate(for url: URL?, cgSize: CGSize) async -> Image? {
        guard let url else { return nil }

        let size = cgSize

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: 1,
            representationTypes: .thumbnail
        )

        do {
            let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            return Image(uiImage: thumbnail.uiImage)
        } catch {
            Logger.general.error("An error occured while generating a thumbnail: \(error)")
        }
        return nil
    }
}
