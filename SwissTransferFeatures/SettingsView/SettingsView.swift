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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

// TODO: i18n needed for links. A ticket was created.
/// Links used in the settings view
enum SettingLinks {
    static let discoverInfomaniak = URL(string: "https://www.infomaniak.com/en/about")!
    static let shareYourIdeas =
        URL(string: "https://feedback.userreport.com/f12466ad-db5b-4f5c-b24c-a54b0a5117ca/#ideas/popular")!
}

public struct SettingsView: View {
    @LazyInjectService private var settingsManager: AppSettingsManager

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
                             leftIconAsset: STResourcesAsset.Images.brush) {
                    EditSettingView(Theme.self,
                                    selected: appSettings.value?.theme ?? .system,
                                    title: STResourcesStrings.Localizable.settingsOptionTheme,
                                    section: STResourcesStrings.Localizable.settingsThemeTitle) { theme in
                        await theme.setSelected()
                    }
                }

                NotificationsSettingsCell {
                    NotificationsSettingsView()
                }
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDefaultSettings)) {
                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                             subtitle: appSettings.value?.validityPeriod.title ?? "",
                             leftIconAsset: STResourcesAsset.Images.clock) {
                    EditSettingView(ValidityPeriod.self,
                                    selected: appSettings.value?.validityPeriod ?? .thirty,
                                    title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                                    section: STResourcesStrings.Localizable.settingsValidityPeriodTitle) { validity in
                        await validity.setSelected()
                    }
                }

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                             subtitle: appSettings.value?.downloadLimit.title ?? "",
                             leftIconAsset: STResourcesAsset.Images.fileDownload) {
                    EditSettingView(DownloadLimit.self,
                                    selected: appSettings.value?.downloadLimit ?? .twoHundredFifty,
                                    title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                                    section: STResourcesStrings.Localizable.settingsDownloadsLimitTitle) { downloadLimit in
                        await downloadLimit.setSelected()
                    }
                }

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                             subtitle: appSettings.value?.emailLanguage.title ?? "",
                             leftIconAsset: STResourcesAsset.Images.bubble) {
                    EditSettingView(EmailLanguage.self,
                                    selected: appSettings.value?.emailLanguage ?? .french,
                                    title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                                    section: STResourcesStrings.Localizable.settingsEmailLanguageTitle) { emailLanguage in
                        await emailLanguage.setSelected()
                    }
                }
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDataManagement)) {
                SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDataManagement)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryAbout)) {
                Link(destination: SettingLinks.discoverInfomaniak) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                                            rightIconAsset: STResourcesAsset.Images.export)
                }

                Link(destination: SettingLinks.shareYourIdeas) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                                            rightIconAsset: STResourcesAsset.Images.export)
                }

                Button {
                    @InjectService var reviewManager: ReviewManageable
                    reviewManager.requestReview()
                } label: {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                                            rightIconAsset: STResourcesAsset.Images.export)
                }

                AboutSettingsCell(title: STResourcesStrings.Localizable.version,
                                  subtitle: CorePlatform.appVersionLabel(fallbackAppName: "SwissTransfer"))
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    SettingsView()
}
