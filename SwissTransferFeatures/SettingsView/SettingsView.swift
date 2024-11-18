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
                let theme = SettingItemIdentifier.theme.item(for: appSettings.value)
                SettingsCell(setting: theme)
                    .tag(SettingItemIdentifier.theme.navigationDestination)

                let notifications = SettingItemIdentifier.notifications.item(for: appSettings.value)
                SettingsCell(setting: notifications)
                    .tag(SettingItemIdentifier.notifications.navigationDestination)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDefaultSettings)) {
                let validityPeriod = SettingItemIdentifier.validityPeriod.item(for: appSettings.value)
                SettingsCell(setting: validityPeriod)
                    .tag(SettingItemIdentifier.validityPeriod.navigationDestination)

                let downloadLimit = SettingItemIdentifier.downloadLimit.item(for: appSettings.value)
                SettingsCell(setting: downloadLimit)
                    .tag(SettingItemIdentifier.downloadLimit.navigationDestination)

                let emailLanguage = SettingItemIdentifier.emailLanguage.item(for: appSettings.value)
                SettingsCell(setting: emailLanguage)
                    .tag(SettingItemIdentifier.emailLanguage.navigationDestination)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDataManagement)) {
                let dataManagement = SettingItemIdentifier.dataManagement.item(for: appSettings.value)
                SingleLabelSettingsCell(title: dataManagement.title)
                    .tag(SettingItemIdentifier.dataManagement.navigationDestination)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryAbout)) {
                let discoverIk = SettingItemIdentifier.discoverIk.item(for: appSettings.value)
                Link(destination: SettingLinks.discoverInfomaniak) {
                    SingleLabelSettingsCell(title: discoverIk.title,
                                            rightIconAsset: discoverIk.rightIconAsset)
                }

                let shareIdeas = SettingItemIdentifier.shareIdeas.item(for: appSettings.value)
                Link(destination: SettingLinks.shareYourIdeas) {
                    SingleLabelSettingsCell(title: shareIdeas.title,
                                            rightIconAsset: shareIdeas.rightIconAsset)
                }

                Button {
                    @InjectService var reviewManager: ReviewManageable
                    reviewManager.requestReview()
                } label: {
                    let feedback = SettingItemIdentifier.feedback.item(for: appSettings.value)
                    SingleLabelSettingsCell(title: feedback.title,
                                            rightIconAsset: feedback.rightIconAsset)
                }

                let version = SettingItemIdentifier.version.item(for: appSettings.value)
                AboutSettingsCell(title: version.title,
                                  subtitle: version.subtitle ?? "")
            }
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            if case .settings(let screen) = destination {
                switch screen {
                case .theme, .validityPeriod, .downloadLimit, .emailLanguage:
                    EditSettingView(model: screen.model(with: appSettings.value))

                case .notifications:
                    NotificationsSettings()

                case .dataManagement:
                    Text("TODO dataManagement")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    SettingsView()
}
