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
import STResources

enum STTab: String, CaseIterable, Identifiable {
    case sentTransfers
    case receivedTransfers
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .sentTransfers:
            return STResourcesStrings.Localizable.sentTitle
        case .receivedTransfers:
            return STResourcesStrings.Localizable.receivedTitle
        case .settings:
            return STResourcesStrings.Localizable.settingsTitle
        }
    }

    var icon: Image {
        switch self {
        case .sentTransfers:
            return STResourcesAsset.Images.arrowUpCircle.swiftUIImage
        case .receivedTransfers:
            return STResourcesAsset.Images.arrowDownCircle.swiftUIImage
        case .settings:
            return STResourcesAsset.Images.sliderVertical3.swiftUIImage
        }
    }

    var label: Label<Text, Image> {
        Label(title: { Text(title) }, icon: { icon })
    }
}
