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
import InfomaniakCore
import STCore
import STResources

/// Holds all what is necessary to display _any_ root level setting cell
public struct SettingItem {
    public let title: String
    public var subtitle: String?
    public var leftIconAsset: STResourcesImages?
    public var rightIconAsset: STResourcesImages?
}

/// The identifier of any specific arbitrary setting view
public enum SettingItemIdentifier: Hashable, Sendable {
    /// All settings in the `New Transfer` view
    public static let newTransferSettings: [SettingItemIdentifier] = [
        .validityPeriod,
        .downloadLimit,
        .password,
        .emailLanguage
    ]

    case theme
    case notifications
    case validityPeriod
    case downloadLimit
    case emailLanguage
    case dataManagement
    case discoverIk
    case shareIdeas
    case feedback
    case version
    case password

    public var navigationDestination: NavigationDestination? {
        guard let settingDetailUi else {
            return nil
        }

        return NavigationDestination.settings(settingDetailUi)
    }

    public var settingDetailUi: SettingDetailUi? {
        switch self {
        case .theme:
            return .theme
        case .notifications:
            return .notifications
        case .validityPeriod:
            return .validityPeriod
        case .downloadLimit:
            return .downloadLimit
        case .emailLanguage:
            return .emailLanguage
        case .dataManagement:
            return .dataManagement
        default:
            return nil
        }
    }

    public func item(for appSettings: AppSettings?) -> SettingItem {
        switch self {
        case .theme:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionTheme,
                               subtitle: appSettings?.theme.title ?? "",
                               leftIconAsset: STResourcesAsset.Images.brush,
                               rightIconAsset: nil)

        case .notifications:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionNotifications,
                               subtitle: NotificationSettings().enabledNotificationLabel,
                               leftIconAsset: STResourcesAsset.Images.bell)

        case .validityPeriod:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                               subtitle: appSettings?.validityPeriod.title ?? "",
                               leftIconAsset: STResourcesAsset.Images.clock)

        case .downloadLimit:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                               subtitle: appSettings?.downloadLimit.title ?? "",
                               leftIconAsset: STResourcesAsset.Images.fileDownload)

        case .emailLanguage:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                               subtitle: appSettings?.emailLanguage.title ?? "",
                               leftIconAsset: STResourcesAsset.Images.bubble)

        case .dataManagement:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionDataManagement)

        case .discoverIk:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                               rightIconAsset: STResourcesAsset.Images.export)

        case .shareIdeas:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                               rightIconAsset: STResourcesAsset.Images.export)

        case .feedback:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                               rightIconAsset: STResourcesAsset.Images.export)

        case .version:
            return SettingItem(title: STResourcesStrings.Localizable.version,
                               subtitle: CorePlatform.appVersionLabel(fallbackAppName: "SwissTransfer"))

        case .password:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionPassword,
                               subtitle: STResourcesStrings.Localizable.settingsOptionNone,
                               leftIconAsset: STResourcesAsset.Images.textfieldLock)
        }
    }
}
