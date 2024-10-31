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

public enum TransferType: String, CaseIterable {
    case link
    case qrcode
    case proximity
    case mail

    public var title: String {
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

    public var icon: Image {
        switch self {
        case .link:
            STResourcesAsset.Images.hyperlink.swiftUIImage
        case .mail:
            STResourcesAsset.Images.envelope.swiftUIImage
        case .qrcode:
            STResourcesAsset.Images.qrCode.swiftUIImage
        case .proximity:
            STResourcesAsset.Images.wifi.swiftUIImage
        }
    }
}