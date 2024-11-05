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

import STResources
import SwiftUI

enum UploadProgressAd: CaseIterable {
    case confidentiality
    case energy
    case independence

    static func getRandomElement() -> UploadProgressAd {
        let allCases = Self.allCases
        return allCases.randomElement() ?? .confidentiality
    }

    var description: AttributedString {
        var result = AttributedString(template(argument))
        result.font = .ST.specificTitle2Light

        guard let argumentRange = result.range(of: argument) else {
            return result
        }
        result[argumentRange].font = .ST.title2

        return result
    }

    var image: Image {
        switch self {
        case .confidentiality:
            return STResourcesAsset.Images.metallicSafe.swiftUIImage
        case .energy:
            return STResourcesAsset.Images.mountainGondola.swiftUIImage
        case .independence:
            return STResourcesAsset.Images.swissWithFlag.swiftUIImage
        }
    }

    private var template: (Any) -> String {
        switch self {
        case .confidentiality:
            return STResourcesStrings.Localizable.uploadProgressDescriptionTemplateConfidentiality
        case .energy:
            return STResourcesStrings.Localizable.uploadProgressDescriptionTemplateEnergy
        case .independence:
            return STResourcesStrings.Localizable.uploadProgressDescriptionTemplateIndependence
        }
    }

    private var argument: String {
        switch self {
        case .confidentiality:
            return STResourcesStrings.Localizable.uploadProgressDescriptionArgumentConfidentiality
        case .energy:
            return STResourcesStrings.Localizable.uploadProgressDescriptionArgumentEnergy
        case .independence:
            return STResourcesStrings.Localizable.uploadProgressDescriptionArgumentIndependence
        }
    }
}
