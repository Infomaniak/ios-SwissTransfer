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

import Lottie
import STResources
import SwiftUI

struct ThemedLottieAnimation: Sendable {
    let light: String
    let dark: String

    func name(for scheme: ColorScheme) -> String {
        return scheme == .light ? light : dark
    }
}

enum UploadProgressAd: CaseIterable {
    case energy
    case independence

    static func getRandomElement() -> UploadProgressAd {
        let allCases = Self.allCases
        return allCases.randomElement() ?? energy
    }

    var animation: ThemedLottieAnimation {
        switch self {
        case .energy:
            return ThemedLottieAnimation(
                light: "mountainGondola",
                dark: "mountainGondolaDark"
            )
        case .independence:
            return ThemedLottieAnimation(
                light: "swissWithFlag",
                dark: "swissWithFlagDark"
            )
        }
    }

    var description: AttributedString {
        var result = AttributedString(template(argument))
        result.font = .ST.specificTitle2Light

        if let argumentRange = result.range(of: argument) {
            result[argumentRange].font = .ST.title2
        }

        return result
    }

    private var template: (Any) -> String {
        switch self {
        case .energy:
            return STResourcesStrings.Localizable.uploadProgressDescriptionTemplateEnergy
        case .independence:
            return STResourcesStrings.Localizable.uploadProgressDescriptionTemplateIndependence
        }
    }

    private var argument: String {
        switch self {
        case .energy:
            return STResourcesStrings.Localizable.uploadProgressDescriptionArgumentEnergy
        case .independence:
            return STResourcesStrings.Localizable.uploadProgressDescriptionArgumentIndependence
        }
    }
}
