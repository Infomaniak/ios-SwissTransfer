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

public enum TransferLanguage: CaseIterable {
    case en
    case fr
    case de
    case it
    case es

    public var title: String {
        switch self {
        case .en: "Anglais"
        case .fr: "Francais"
        case .de: "Allemand"
        case .it: "Italien"
        case .es: "Espagnol"
        }
    }

    public var flag: Image {
        switch self {
        case .en: STResourcesAsset.Images.flagEn.swiftUIImage
        case .fr: STResourcesAsset.Images.flagFr.swiftUIImage
        case .de: STResourcesAsset.Images.flagDe.swiftUIImage
        case .it: STResourcesAsset.Images.flagIt.swiftUIImage
        case .es: STResourcesAsset.Images.flagEs.swiftUIImage
        }
    }
}
