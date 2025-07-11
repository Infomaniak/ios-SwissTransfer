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

import InfomaniakCoreCommonUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI

extension EmailLanguage: SettingSelectable {
    public var title: String {
        switch self {
        case .english: STResourcesStrings.Localizable.settingsEmailLanguageValueEnglish
        case .french: STResourcesStrings.Localizable.settingsEmailLanguageValueFrench
        case .german: STResourcesStrings.Localizable.settingsEmailLanguageValueGerman
        case .italian: STResourcesStrings.Localizable.settingsEmailLanguageValueItalian
        case .spanish: STResourcesStrings.Localizable.settingsEmailLanguageValueSpanish
        }
    }

    public var leftImage: Image? {
        switch self {
        case .english:
            return STResourcesAsset.Images.flagEn.swiftUIImage
        case .french:
            return STResourcesAsset.Images.flagFr.swiftUIImage
        case .german:
            return STResourcesAsset.Images.flagDe.swiftUIImage
        case .italian:
            return STResourcesAsset.Images.flagIt.swiftUIImage
        case .spanish:
            return STResourcesAsset.Images.flagEs.swiftUIImage
        }
    }

    public var matomoName: String {
        switch self {
        case .english:
            return "english"
        case .french:
            return "french"
        case .german:
            return "german"
        case .italian:
            return "italian"
        case .spanish:
            return "spanish"
        }
    }

    public static var matomoCategoryLocal: MatomoUtils.EventCategory? {
        return .settingsLocalEmailLanguage
    }

    public static var matomoCategoryGlobal: MatomoUtils.EventCategory? {
        return .settingsGlobalEmailLanguage
    }

    public func setSelected() async {
        @InjectService var settingsManager: AppSettingsManager
        _ = try? await settingsManager.setEmailLanguage(emailLanguage: self)
    }
}
