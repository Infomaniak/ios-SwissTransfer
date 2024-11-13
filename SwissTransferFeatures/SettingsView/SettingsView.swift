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

    @MainActor func settingCellView(setting: SettingItemIdentifier) -> some View {
        let datasource = setting.item(for: appSettings.value)

        switch setting {
        case .theme, .notifications, .validityPeriod, .downloadLimit, .emailLanguage:
            return SettingsCell(title: datasource.title,
                                subtitle: datasource.subtitle ?? "",
                                leftIconAsset: datasource.leftIconAsset,
                                rightIconAsset: datasource.rightIconAsset)
                .optionalTag(setting.navigationDestination)

        case .dataManagement:
            return SingleLabelSettingsCell(title: datasource.title)
                .optionalTag(setting.navigationDestination)

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

        case .password:
            return EmptyView() // unsupported on the main settings view.
        }
    }
}

#Preview {
    SettingsView()
}
