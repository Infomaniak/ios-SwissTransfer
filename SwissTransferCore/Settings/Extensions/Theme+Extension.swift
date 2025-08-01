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

import InfomaniakDI
import STCore
import STResources
import SwiftUI

extension Theme: SettingSelectable {
    public var title: String {
        switch self {
        case .dark:
            return STResourcesStrings.Localizable.settingsOptionThemeDark
        case .light:
            return STResourcesStrings.Localizable.settingsOptionThemeLight
        case .system:
            return STResourcesStrings.Localizable.settingsOptionThemeSystem
        }
    }

    public var leftImage: Image? {
        switch self {
        case .dark:
            return STResourcesAsset.Images.circleDark.swiftUIImage
        case .light:
            return STResourcesAsset.Images.circleLight.swiftUIImage
        case .system:
            return STResourcesAsset.Images.circleHalfLightHalfDark.swiftUIImage
        }
    }

    public var matomoName: MatomoName {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .system
        }
    }

    public static var matomoCategoryLocal: MatomoCategory? {
        return nil
    }

    public static var matomoCategoryGlobal: MatomoCategory? {
        return .settingsGlobalTheme
    }

    public func setSelected() async {
        @InjectService var settingsManager: AppSettingsManager
        _ = try? await settingsManager.setTheme(theme: self)
    }
}
