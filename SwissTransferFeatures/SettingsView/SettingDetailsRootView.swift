/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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
import InfomaniakPrivacyManagement
import STCore
import STResources
import SwiftUI
import SwissTransferCore

public struct SettingDetailsRootView: View {
    @InjectService private var matomo: MatomoUtils

    @StateObject private var appSettings: FlowObserver<AppSettings>

    private let setting: SettingDetailUI

    public init(setting: SettingDetailUI) {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
        self.setting = setting
    }

    public var body: some View {
        switch setting {
        case .theme:
            EditSettingView(
                Theme.self,
                selected: appSettings.value?.theme ?? .system,
                title: STResourcesStrings.Localizable.settingsOptionTheme,
                section: STResourcesStrings.Localizable.settingsThemeTitle,
                matomoScreen: .themeSetting
            )

        case .notifications:
            NotificationsSettingsView()

        case .validityPeriod:
            EditSettingView(ValidityPeriod.self,
                            selected: appSettings.value?.validityPeriod ?? .thirty,
                            title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                            section: STResourcesStrings.Localizable.settingsValidityPeriodTitle,
                            matomoScreen: .validityPeriodSetting)

        case .downloadLimit:
            EditSettingView(DownloadLimit.self,
                            selected: appSettings.value?.downloadLimit ?? .twoHundredFifty,
                            title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                            section: STResourcesStrings.Localizable.settingsDownloadsLimitTitle,
                            matomoScreen: .downloadLimitSetting)

        case .emailLanguage:
            EditSettingView(EmailLanguage.self,
                            selected: appSettings.value?.emailLanguage ?? .french,
                            title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                            section: STResourcesStrings.Localizable.settingsEmailLanguageTitle,
                            matomoScreen: .emailLanguageSetting)

        case .dataManagement:
            PrivacyManagementView(
                urlRepository: SettingLinks.githubRepository,
                backgroundColor: Color.ST.background,
                illustration: STResourcesAsset.Images.documentSignaturePencilBulb.swiftUIImage,
                userDefaultStore: .shared,
                userDefaultKeyMatomo: UserDefaults.shared.key(.matomoAuthorized),
                userDefaultKeySentry: UserDefaults.shared.key(.sentryAuthorized),
                showTitle: false,
                matomo: matomo
            )
            .stNavigationTitle(PrivacyManagementView.title)
            .stNavigationBarStyle()
        }
    }
}
