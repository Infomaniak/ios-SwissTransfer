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
import STResources
import UniformTypeIdentifiers

public struct FileHelper {
    public var type: String

    public var uti: UTType? {
        UTType(mimeType: type, conformingTo: .data)
    }

    // TODO: - Fill with all uti and all icon
    public var icon: STResourcesImages {
        guard let uti else {
            return STResourcesAsset.Images.fileAdobe
        }

        if uti.conforms(to: .pdf) {
            return STResourcesAsset.Images.fileAdobe
        } else if uti.conforms(to: .presentation) {
            return STResourcesAsset.Images.fileGraph
        } else if uti.conforms(to: .spreadsheet) {
            return STResourcesAsset.Images.fileSheet
        } else if uti.conforms(to: .movie) {
            return STResourcesAsset.Images.fileVideo
        } else {
            return STResourcesAsset.Images.fileAdobe
        }
    }
}
