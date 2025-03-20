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
enum SettingLinks {
    static let discoverInfomaniak = URL(string: STResourcesStrings.Localizable.urlAbout)!
    static let shareYourIdeas = URL(string: STResourcesStrings.Localizable.urlUserReport)!
    static let githubRepository = URL(string: "https://github.com/Infomaniak/ios-SwissTransfer")!
    static let termsAndConditions = URL(string: "https://www.swisstransfer.com/?cgu")!
    static let appStoreReviewURL = URL(string: "https://apps.apple.com/app/id6737686335?action=write-review")!
    static let betaVersionApp = URL(string: "https://testflight.apple.com/join/bnHmqCvT")!
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
                                    matomoName: "ThemeSettingView")
                }
                .settingsCell()

                NotificationsSettingsCell {
                    NotificationsSettingsView()
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
                                    matomoName: "ValidityPeriodSettingView")
                }
                .settingsCell()

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                             subtitle: appSettings.value?.downloadLimit.title ?? "",
                             icon: STResourcesAsset.Images.fileDownload) {
                    EditSettingView(DownloadLimit.self,
                                    selected: appSettings.value?.downloadLimit ?? .twoHundredFifty,
                                    title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                                    section: STResourcesStrings.Localizable.settingsDownloadsLimitTitle,
                                    matomoName: "DownloadLimitSettingView")
                }
                .settingsCell()

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                             subtitle: appSettings.value?.emailLanguage.title ?? "",
                             icon: STResourcesAsset.Images.bubble) {
                    EditSettingView(EmailLanguage.self,
                                    selected: appSettings.value?.emailLanguage ?? .french,
                                    title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                                    section: STResourcesStrings.Localizable.settingsEmailLanguageTitle,
                                    matomoName: "EmailLanguageSettingView")
                }
                .settingsCell()
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDataManagement)) {
                NavigationLink {
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
                } label: {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDataManagement,
                                            leadingIcon: STResourcesAsset.Images.shield)
                }
                .settingsCell()
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryAbout)) {
                Link(destination: SettingLinks.termsAndConditions) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionTermsAndConditions,
                                            trailingIcon: STResourcesAsset.Images.export)
                }
                .settingsCell()

                Link(destination: SettingLinks.discoverInfomaniak) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                                            trailingIcon: STResourcesAsset.Images.export)
                }
                .settingsCell()

                Link(destination: SettingLinks.shareYourIdeas) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                                            trailingIcon: STResourcesAsset.Images.export)
                }
                .settingsCell()

                if !Bundle.main.isRunningInTestFlight {
                    Link(destination: SettingLinks.appStoreReviewURL) {
                        SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                                                trailingIcon: STResourcesAsset.Images.export)
                    }
                    .settingsCell()

                    Link(destination: SettingLinks.betaVersionApp) {
                        SingleLabelSettingsCell(title: CoreUILocalizable.joinTheBetaButton,
                                                trailingIcon: STResourcesAsset.Images.export)
                    }
                    .settingsCell()
                }

                AboutSettingsCell(title: STResourcesStrings.Localizable.version,
                                  subtitle: CorePlatform.appVersionLabel(fallbackAppName: "SwissTransfer"))
                    .settingsCell()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appBackground()
        .matomoView(view: "SettingsView")
    }
}

#Preview {
    SettingsView()
}
