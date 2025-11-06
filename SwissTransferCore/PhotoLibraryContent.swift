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

import SwiftUI

public struct PhotoLibraryContent: Transferable {
    public let url: URL

    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) {
            SentTransferredFile($0.url)
        } importing: {
            let cacheURL = try FileManager.destinationURLFor(source: $0.file, to: URL.tmpCacheDirectory())
            try FileManager.default.copyItem(at: $0.file, to: cacheURL)
            return Self(url: cacheURL)
        }
        FileRepresentation(contentType: .image) {
            SentTransferredFile($0.url)
        } importing: {
            let cacheURL = try FileManager.destinationURLFor(source: $0.file, to: URL.tmpCacheDirectory())
            try FileManager.default.copyItem(at: $0.file, to: cacheURL)
            return Self(url: cacheURL)
        }
    }
}
