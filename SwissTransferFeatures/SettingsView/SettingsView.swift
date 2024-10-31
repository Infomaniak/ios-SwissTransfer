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
import SwissTransferCore
import SwissTransferCoreUI

public struct SettingsView: View {
    @LazyInjectService var settingsManager: AppSettingsManager

    @StateObject var appSettings: FlowObserver<AppSettings>

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    public var body: some View {
        List {
            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryGeneral)) {
                SettingsCell(title: STResourcesStrings.Localizable.settingsThemeTitle,
                             subtitle: STResourcesStrings.Localizable.settingsOptionThemeLight,
                             leftIconAsset: STResourcesAsset.Images.brush,
                             rightIconAsset: STResourcesAsset.Images.chevronRight)

                SettingsCell(title: STResourcesStrings.Localizable.settingsNotificationsTitle,
                             subtitle: "Tout recevoir",
                             leftIconAsset: STResourcesAsset.Images.bell,
                             rightIconAsset: STResourcesAsset.Images.chevronRight)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDefaultSettings)) {
                SettingsCell(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                             subtitle: "30 jours",
                             leftIconAsset: STResourcesAsset.Images.clock,
                             rightIconAsset: STResourcesAsset.Images.chevronRight)

                SettingsCell(title: STResourcesStrings.Localizable.settingsDownloadsLimitTitle,
                             subtitle: "250",
                             leftIconAsset: STResourcesAsset.Images.fileDownload,
                             rightIconAsset: STResourcesAsset.Images.chevronRight)

                SettingsCell(title: STResourcesStrings.Localizable.settingsEmailLanguageTitle,
                             subtitle: "Frouze",
                             leftIconAsset: STResourcesAsset.Images.bubble,
                             rightIconAsset: STResourcesAsset.Images.chevronRight)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDataManagement)) {
                SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDataManagement,
                                        rightIconAsset: STResourcesAsset.Images.chevronRight)
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryAbout)) {
                SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                                        rightIconAsset: STResourcesAsset.Images.export)

                SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                                        rightIconAsset: STResourcesAsset.Images.export)

                SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                                        rightIconAsset: STResourcesAsset.Images.export)

                AboutSettingsCell(title: STResourcesStrings.Localizable.version, subtitle: "4.20")
            }

            Section(header: Text("demo")) {
                Text("SettingsView")
                if let appSettings = appSettings.value {
                    Text(appSettings.theme.name)
                }
                Button("Toggle") {
                    Task {
                        if let appSettings = appSettings.value {
                            try? await settingsManager.setTheme(theme: appSettings.theme == .dark ? .light : .dark)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    SettingsView()
}
