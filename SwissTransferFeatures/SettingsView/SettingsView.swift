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
import StoreKit
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

enum SettingLinks {
    static let discoverInfomaniak = URL(string: "https://www.infomaniak.com/en/about")!
    static let shareYourIdeas =
        URL(string: "https://feedback.userreport.com/f12466ad-db5b-4f5c-b24c-a54b0a5117ca/#ideas/popular")!
}

/// Holds all what is necessary to display _any_ root level setting cell
struct SettingItem {
    let title: String
    var subtitle: String?
    var leftIconAsset: STResourcesImages?
    var rightIconAsset: STResourcesImages?
}

/// The identifier of any setting
enum SettingItemIdentifier: Hashable {
    case theme
    case notifications
    case validityPeriod
    case downloadLimit
    case emailLanguage
    case dataManagement
    case discoverIk
    case shareIdeas
    case feedback
    case version

    var tag: SettingDetailUi? {
        switch self {
        case .theme:
            return .theme
        case .notifications:
            return .notifications
        case .validityPeriod:
            return .validityPeriod
        case .downloadLimit:
            return .downloadLimit
        case .emailLanguage:
            return .emailLanguage
        case .dataManagement:
            return .dataManagement
        default:
            return nil
        }
    }

    func item(for appSettings: AppSettings?) -> SettingItem {
        switch self {
        case .theme:
            let themeName = appSettings?.theme.localized ?? ""
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionTheme,
                               subtitle: themeName,
                               leftIconAsset: STResourcesAsset.Images.brush,
                               rightIconAsset: nil)

        case .notifications:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionNotifications,
                               subtitle: "",
                               leftIconAsset: STResourcesAsset.Images.bell)

        case .validityPeriod:
            let validityPeriod = appSettings?.validityPeriod.localized ?? ""
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                               subtitle: validityPeriod,
                               leftIconAsset: STResourcesAsset.Images.clock)

        case .downloadLimit:
            let downloadLimit = appSettings?.downloadLimit.localized ?? ""
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                               subtitle: downloadLimit,
                               leftIconAsset: STResourcesAsset.Images.fileDownload)

        case .emailLanguage:
            let emailLanguage = appSettings?.emailLanguage.localized ?? ""
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                               subtitle: emailLanguage,
                               leftIconAsset: STResourcesAsset.Images.bubble)

        case .dataManagement:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionDataManagement)

        case .discoverIk:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                               rightIconAsset: STResourcesAsset.Images.export)

        case .shareIdeas:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                               rightIconAsset: STResourcesAsset.Images.export)

        case .feedback:
            return SettingItem(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                               rightIconAsset: STResourcesAsset.Images.export)

        case .version:
            return SettingItem(title: STResourcesStrings.Localizable.version,
                               subtitle: CorePlatform.appVersionLabel(fallbackAppName: "SwissTransfer"))
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
            [.discoverIk, .shareIdeas, .feedback, .version]
        }
    }
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
            ForEach(SettingSections.allCases, id: \.self) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.items, id: \.self) { item in
                        settingCellView(setting: item)
                    }
                }
            }
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            if case .settings(let screen) = destination {
                switch screen {
                case .theme:
                    EditSettingView(datasource: EditThemeDatasource(appSettings: appSettings.value))
                case .validityPeriod:
                    EditSettingView(datasource: EditValidityPeriodDatasource(appSettings: appSettings.value))
                case .downloadLimit:
                    EditSettingView(datasource: EditDownloadLimitDatasource(appSettings: appSettings.value))
                case .emailLanguage:
                    EditSettingView(datasource: EditEmailLanguageDatasource(appSettings: appSettings.value))
                case .notifications:
                    NotificationsSettings()
                case .dataManagement:
                    Text("TODO dataManagement")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @MainActor func settingCellView(setting: SettingItemIdentifier) -> some View {
        let appSettings: AppSettings? = self.appSettings.value
        let datasource = setting.item(for: appSettings)

        switch setting {
        case .theme, .notifications, .validityPeriod, .downloadLimit, .emailLanguage:
            var cell: any View = SettingsCell(title: datasource.title,
                                              subtitle: datasource.subtitle ?? "",
                                              leftIconAsset: datasource.leftIconAsset,
                                              rightIconAsset: datasource.rightIconAsset)
            if let tag = setting.tag {
                cell = cell.tag(NavigationDestination.settings(tag))
            }

            return cell

        case .dataManagement:
            return SingleLabelSettingsCell(title: datasource.title)
                .tag(NavigationDestination.settings(.dataManagement))

        case .discoverIk:
            return Link(destination: SettingLinks.discoverInfomaniak) {
                SingleLabelSettingsCell(title: datasource.title,
                                        rightIconAsset: datasource.rightIconAsset)
            }

        case .shareIdeas:
            return Link(destination: SettingLinks.shareYourIdeas) {
                SingleLabelSettingsCell(title: datasource.title,
                                        rightIconAsset: datasource.rightIconAsset)
            }

        case .feedback:
            return Button {
                @InjectService var reviewManager: ReviewManageable
                reviewManager.requestReview()
            } label: {
                SingleLabelSettingsCell(title: datasource.title,
                                        rightIconAsset: datasource.rightIconAsset)
            }

        case .version:
            return AboutSettingsCell(title: datasource.title,
                                     subtitle: datasource.subtitle ?? "")
        }
    }
}

#Preview {
    SettingsView()
}
