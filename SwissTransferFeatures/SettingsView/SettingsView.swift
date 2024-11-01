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
    case validity
    case timeLimit
    case emailLanguage
    case dataManagement
    case discoverCorpo
    case shareIdeas
    case feedback
    case version

    var cell: some View {
        switch self {
        case .theme:
            return SettingsCell(title: STResourcesStrings.Localizable.settingsThemeTitle,
                                subtitle: STResourcesStrings.Localizable.settingsOptionThemeLight,
                                leftIconAsset: STResourcesAsset.Images.brush,
                                rightIconAsset: STResourcesAsset.Images.chevronRight)

        case .notifications:
            return SettingsCell(title: STResourcesStrings.Localizable.settingsNotificationsTitle,
                                subtitle: "Tout recevoir",
                                leftIconAsset: STResourcesAsset.Images.bell,
                                rightIconAsset: STResourcesAsset.Images.chevronRight)

        case .validity:
            return SettingsCell(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                                subtitle: "30 jours",
                                leftIconAsset: STResourcesAsset.Images.clock,
                                rightIconAsset: STResourcesAsset.Images.chevronRight)

        case .timeLimit:
            return SettingsCell(title: STResourcesStrings.Localizable.settingsDownloadsLimitTitle,
                                subtitle: "250",
                                leftIconAsset: STResourcesAsset.Images.fileDownload,
                                rightIconAsset: STResourcesAsset.Images.chevronRight)

        case .emailLanguage:
            return SettingsCell(title: STResourcesStrings.Localizable.settingsEmailLanguageTitle,
                                subtitle: "Frouze",
                                leftIconAsset: STResourcesAsset.Images.bubble,
                                rightIconAsset: STResourcesAsset.Images.chevronRight)

        case .dataManagement:
            return SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDataManagement,
                                           rightIconAsset: STResourcesAsset.Images.chevronRight)

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
            [.validity, .timeLimit, .emailLanguage]
        case .dataManagement:
            [.dataManagement]
        case .about:
            [.discoverCorpo, .shareIdeas, .feedback, .version]
        }
    }
}

public struct SettingsView: View {
    @LazyInjectService var settingsManager: AppSettingsManager

    @StateObject var appSettings: FlowObserver<AppSettings>

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    public var body: some View {
        List {
            ForEach(SettingSections.allCases, id: \.self) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.items, id: \.self) { item in
                        item.cell
                    }
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
