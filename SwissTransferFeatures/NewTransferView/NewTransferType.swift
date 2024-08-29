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

enum TransferType: String, CaseIterable {
    case link
    case mail
    case qrcode
    case proximity

    var title: String {
        switch self {
        case .link:
            STResourcesStrings.Localizable.transferTypeLink
        case .mail:
            STResourcesStrings.Localizable.transferTypeEmail
        case .qrcode:
            STResourcesStrings.Localizable.transferTypeQrCode
        case .proximity:
            STResourcesStrings.Localizable.transferTypeProximity
        }
    }

    var foregroundColor: Color {
        switch self {
        case .link:
            Color.ST.primary
        case .mail:
            Color.ST.secondary
        case .qrcode:
            Color.ST.primary
        case .proximity:
            STResourcesAsset.Colors.specific4.swiftUIColor
        }
    }

    var backgroundColor: Color {
        switch self {
        case .link:
            STResourcesAsset.Colors.specific1.swiftUIColor
        case .mail:
            STResourcesAsset.Colors.specific2.swiftUIColor
        case .qrcode:
            STResourcesAsset.Colors.greenSecondary.swiftUIColor
        case .proximity:
            STResourcesAsset.Colors.specific3.swiftUIColor
        }
    }

    var icon: Image {
        switch self {
        case .link:
            STResourcesAsset.Images.bigLink.swiftUIImage
        case .mail:
            STResourcesAsset.Images.bigMail.swiftUIImage
        case .qrcode:
            STResourcesAsset.Images.bigQrCode.swiftUIImage
        case .proximity:
            STResourcesAsset.Images.bigWifi.swiftUIImage
        }
    }
}
