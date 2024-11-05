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

import STCore
import STResources

public extension EmailLanguage {
    var localized: String {
        switch self {
        case .english:
            return STResourcesStrings.Localizable.settingsEmailLanguageValueEnglish
        case .french:
            return STResourcesStrings.Localizable.settingsEmailLanguageValueFrench
        case .german:
            return STResourcesStrings.Localizable.settingsEmailLanguageValueGerman
        case .italian:
            return STResourcesStrings.Localizable.settingsEmailLanguageValueItalian
        case .spanish:
            return STResourcesStrings.Localizable.settingsEmailLanguageValueSpanish
        }
    }

    var leftIcon: STResourcesImages {
        switch self {
        case .english:
            return STResourcesAsset.Images.flagUk
        case .french:
            return STResourcesAsset.Images.flagFr
        case .german:
            return STResourcesAsset.Images.flagDe
        case .italian:
            return STResourcesAsset.Images.flagIt
        case .spanish:
            return STResourcesAsset.Images.flagEs
        }
    }
}
