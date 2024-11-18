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
                    EditSettingView(model: EditThemeSettingsModel(appSettings: appSettings.value))
                }

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionNotifications,
                             subtitle: NotificationSettings().enabledNotificationLabel,
                             leftIconAsset: STResourcesAsset.Images.bell) {
                    NotificationsSettings()
                }
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDefaultSettings)) {
                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                             subtitle: appSettings.value?.validityPeriod.title ?? "",
                             leftIconAsset: STResourcesAsset.Images.clock) {
                    EditSettingView(model: EditValidityPeriodModel(appSettings: appSettings.value))
                }

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                             subtitle: appSettings.value?.downloadLimit.title ?? "",
                             leftIconAsset: STResourcesAsset.Images.fileDownload) {
                    EditSettingView(model: EditDownloadLimitModel(appSettings: appSettings.value))
                }

                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                             subtitle: appSettings.value?.emailLanguage.title ?? "",
                             leftIconAsset: STResourcesAsset.Images.bubble) {
                    EditSettingView(model: EditEmailLanguageModel(appSettings: appSettings.value))
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
