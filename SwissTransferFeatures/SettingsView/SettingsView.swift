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

enum SettingItemIdentifier: Hashable {
    case theme
    case notifications
    case validityPeriod
    case downloadLimit
    case emailLanguage
    case dataManagement
    case discoverCorpo
    case shareIdeas
    case feedback
    case version

    func cell(appSettings: AppSettings?) -> some View {
        switch self {
        case .theme:
            let themeName = appSettings?.theme.localized ?? ""
            return SettingsCell(title: STResourcesStrings.Localizable.settingsOptionTheme,
                                subtitle: themeName,
                                leftIconAsset: STResourcesAsset.Images.brush)
                .tag(NavigationDestination.settings(.theme))

        case .notifications:
            return SettingsCell(title: STResourcesStrings.Localizable.settingsOptionNotifications,
                                subtitle: "TODO",
                                leftIconAsset: STResourcesAsset.Images.bell)
                .tag(NavigationDestination.settings(.notifications))

        case .validityPeriod:
            let validityPeriod = appSettings?.validityPeriod.value ?? ""
            return SettingsCell(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                                subtitle: validityPeriod,
                                leftIconAsset: STResourcesAsset.Images.clock)
                .tag(NavigationDestination.settings(.validityPeriod))

        case .downloadLimit:
            let downloadLimit = appSettings?.downloadLimit.value ?? ""
            return SettingsCell(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                                subtitle: downloadLimit,
                                leftIconAsset: STResourcesAsset.Images.fileDownload)
                .tag(NavigationDestination.settings(.downloadLimit))

        case .emailLanguage:
            let emailLanguage = appSettings?.emailLanguage.value ?? ""
            return SettingsCell(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                                subtitle: emailLanguage,
                                leftIconAsset: STResourcesAsset.Images.bubble)
                .tag(NavigationDestination.settings(.emailLanguage))

        case .dataManagement:
            return SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDataManagement)
                .tag(NavigationDestination.settings(.dataManagement))

        case .discoverCorpo:
            return SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                                           rightIconAsset: STResourcesAsset.Images.export)

        case .shareIdeas:
            return SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                                           rightIconAsset: STResourcesAsset.Images.export)

        case .feedback:
            return SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                                           rightIconAsset: STResourcesAsset.Images.export)

        case .version:
            return AboutSettingsCell(title: STResourcesStrings.Localizable.version, subtitle: "4.20")
        }
    }
}

enum SettingSections: CaseIterable {
    case general
    case defaultSettings
    case dataManagement
    case about

    var title: String {
        switch self {
        case .general:
            STResourcesStrings.Localizable.settingsCategoryGeneral
        case .defaultSettings:
            STResourcesStrings.Localizable.settingsCategoryDefaultSettings
        case .dataManagement:
            STResourcesStrings.Localizable.settingsCategoryDataManagement
        case .about:
            STResourcesStrings.Localizable.settingsCategoryAbout
        }
    }

    var items: [SettingItemIdentifier] {
        switch self {
        case .general:
            [.theme, .notifications]
        case .defaultSettings:
            [.validityPeriod, .downloadLimit, .emailLanguage]
        case .dataManagement:
            [.dataManagement]
        case .about:
            [.discoverCorpo, .shareIdeas, .feedback, .version]
        }
    }
}

public struct SettingsView: View {
    @LazyInjectService private var settingsManager: AppSettingsManager

    @EnvironmentObject private var mainViewState: MainViewState

    @StateObject var appSettings: FlowObserver<AppSettings>

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    public var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            ForEach(SettingSections.allCases, id: \.self) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.items, id: \.self) { item in
                        item.cell(appSettings: appSettings.value)
                    }
                }
            }
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            if case .settings(let screen) = destination {
                switch screen {
                case .theme, .validityPeriod, .downloadLimit, .emailLanguage:
                    EditSettingView(source: screen)

                case .notifications:
                    Text("TODO notifications")

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
