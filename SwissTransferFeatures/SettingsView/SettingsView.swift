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
        // no DividerView() for now …
        List {
            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryGeneral)) {
                SettingsCell(title: "Thème",
                             subtitle: "clear",
                             leftIconAsset: STResourcesAsset.Images.brush,
                             rightIconAsset: STResourcesAsset.Images.chevronRight) {
                    print("coucou")
                }
                SettingsCell(title: "Notifications",
                             subtitle: "Tout recevoir",
                             leftIconAsset: STResourcesAsset.Images.bell,
                             rightIconAsset: STResourcesAsset.Images.chevronRight) {
                    print("coucou")
                }
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryDefaultSettings)) {
                SettingsCell(title: "Durée de validité",
                             subtitle: "30 jours",
                             leftIconAsset: STResourcesAsset.Images.clock,
                             rightIconAsset: STResourcesAsset.Images.chevronRight) {
                    print("coucou")
                }
                SettingsCell(title: "Limite de téléchargements",
                             subtitle: "250",
                             leftIconAsset: STResourcesAsset.Images.fileDownload,
                             rightIconAsset: STResourcesAsset.Images.chevronRight) {
                    print("coucou")
                }
                SettingsCell(title: "Language du mail",
                             subtitle: "French saucisse",
                             leftIconAsset: STResourcesAsset.Images.bubble,
                             rightIconAsset: STResourcesAsset.Images.chevronRight) {
                    print("coucou")
                }
            }

            Section(header: Text("Gestion des données")) {
                SingleLabelSettingsCell(title: "Gestion des données",
                                        rightIconAsset: STResourcesAsset.Images.chevronRight) {
                    print("coucou")
                }
            }

            Section(header: Text("A propos")) {
                SingleLabelSettingsCell(title: "Decouverte infomaniak",
                                        rightIconAsset: STResourcesAsset.Images.export) {
                    print("coucou")
                }
                SingleLabelSettingsCell(title: "Partage test idées",
                                        rightIconAsset: STResourcesAsset.Images.export) {
                    print("coucou")
                }
                SingleLabelSettingsCell(title: "Donne ton avis",
                                        rightIconAsset: STResourcesAsset.Images.export) {
                    print("coucou")
                }
                AboutSettingsCell(title: "Version", subtitle: "4.20") {
                    print("coucou")
                }
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
