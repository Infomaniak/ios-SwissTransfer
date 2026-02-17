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

import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreUIResources
import InfomaniakDI
import InfomaniakPrivacyManagement
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

/// Links used in the settings view
public enum SettingLinks {
    public static let discoverInfomaniak = URL(string: STResourcesStrings.Localizable.urlAbout)!
    public static let shareYourIdeas = URL(string: STResourcesStrings.Localizable.urlUserReport)!
    public static let githubRepository = URL(string: "https://github.com/Infomaniak/ios-SwissTransfer")!
    public static let termsAndConditions = URL(string: "https://www.swisstransfer.com/?cgu")!
    public static let appStoreReviewURL = URL(string: "https://apps.apple.com/app/id6737686335?action=write-review")!
    public static let helpAndSupport = URL(string: "https://support.infomaniak.com")!
}

public struct SettingsView: View {
    @InjectService private var matomo: MatomoUtils

    @EnvironmentObject private var mainViewState: MainViewState

    @StateObject private var appSettings: FlowObserver<AppSettings>

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    public var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryGeneral)) {
                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionTheme,
                             subtitle: appSettings.value?.theme.title ?? "",
                             icon: STResourcesAsset.Images.brush) {
                    EditSettingView(Theme.self,
                                    selected: appSettings.value?.theme ?? .system,
                                    title: STResourcesStrings.Localizable.settingsOptionTheme,
                                    section: STResourcesStrings.Localizable.settingsThemeTitle,
                                    matomoScreen: .themeSetting)
                }
                .settingsCell()
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDefaultSettings)) {
                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                             subtitle: appSettings.value?.validityPeriod.title ?? "",
                             icon: STResourcesAsset.Images.clock) {
                    EditSettingView(ValidityPeriod.self,
                                    selected: appSettings.value?.validityPeriod ?? .thirty,
                                    title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                                    section: STResourcesStrings.Localizable.settingsValidityPeriodTitle,
                                    matomoScreen: .validityPeriodSetting)
                }
                .settingsCell()

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                             subtitle: appSettings.value?.downloadLimit.title ?? "",
                             icon: STResourcesAsset.Images.fileDownload) {
                    EditSettingView(DownloadLimit.self,
                                    selected: appSettings.value?.downloadLimit ?? .twoHundredFifty,
                                    title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                                    section: STResourcesStrings.Localizable.settingsDownloadsLimitTitle,
                                    matomoScreen: .downloadLimitSetting)
                }
                .settingsCell()

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                             subtitle: appSettings.value?.emailLanguage.title ?? "",
                             icon: STResourcesAsset.Images.bubble) {
                    EditSettingView(EmailLanguage.self,
                                    selected: appSettings.value?.emailLanguage ?? .french,
                                    title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                                    section: STResourcesStrings.Localizable.settingsEmailLanguageTitle,
                                    matomoScreen: .emailLanguageSetting)
                }
                .settingsCell()
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDataManagement)) {
                NavigationLink {
                    PrivacyManagementView(
                        urlRepository: SettingLinks.helpAndSupport,
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
                } label: {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDataManagement,
                                            leadingIcon: STResourcesAsset.Images.shield)
                }
                .settingsCell()

                Button {} label: {
                    SingleLabelSettingsCell(
                        title: STResourcesStrings.Localizable.settingsDeleteMyAccount,
                        leadingIcon: STResourcesAsset.Images.delete,
                        trailingIcon: STResourcesAsset.Images.export
                    )
                }
                .settingsCell()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appBackground()
        .matomoView(view: .settings)
    }
}

#Preview {
    SettingsView()
}
