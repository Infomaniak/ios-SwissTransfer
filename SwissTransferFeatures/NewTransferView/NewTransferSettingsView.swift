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

import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct NewTransferSettingsView: View {
    @StateObject private var appSettings: FlowObserver<AppSettings>

    @State private var duration = ValidityPeriod.thirty
    @State private var limit = DownloadLimit.twoHundredFifty
    @State private var language = EmailLanguage.french

    @State private var showPasswordSetting = false
    @State private var isShowingValiditySetting = false
    @State private var isShowingDownloadLimitSetting = false
    @State private var isShowingLanguageSetting = false

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Text(STResourcesStrings.Localizable.advancedSettingsTitle)
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textPrimary)

            VStack(alignment: .leading, spacing: IKPadding.medium) {
                let validityItem = settingItem(setting: .validityPeriod)
                NewTransferSettingCell(
                    title: validityItem.title,
                    icon: validityItem.leftIconAsset?.swiftUIImage,
                    value: validityItem.subtitle ?? ""
                ) {
                    isShowingValiditySetting = true
                }
                .floatingPanel(
                    isPresented: $isShowingValiditySetting,
                    title: STResourcesStrings.Localizable.settingsOptionValidityPeriod
                ) {
                    SettingSelectableList(ValidityPeriod.self, selected: duration) {
                        duration = $0
                    }
                }

                let downloadLimitItem = settingItem(setting: .downloadLimit)
                NewTransferSettingCell(
                    title: downloadLimitItem.title,
                    icon: downloadLimitItem.leftIconAsset?.swiftUIImage,
                    value: downloadLimitItem.subtitle ?? ""
                ) {
                    isShowingDownloadLimitSetting = true
                }
                .floatingPanel(
                    isPresented: $isShowingDownloadLimitSetting,
                    title: STResourcesStrings.Localizable.settingsOptionDownloadLimit
                ) {
                    SettingSelectableList(DownloadLimit.self, selected: limit) {
                        limit = $0
                    }
                }

                let passwordItem = settingItem(setting: .password)
                NewTransferSettingCell(
                    title: passwordItem.title,
                    icon: passwordItem.leftIconAsset?.swiftUIImage,
                    value: passwordItem.subtitle ?? ""
                ) {
                    showPasswordSetting = true
                }

                let emailItem = settingItem(setting: .emailLanguage)
                NewTransferSettingCell(
                    title: emailItem.title,
                    icon: emailItem.leftIconAsset?.swiftUIImage,
                    value: emailItem.subtitle ?? ""
                ) {
                    isShowingLanguageSetting = true
                }

                .floatingPanel(
                    isPresented: $isShowingLanguageSetting,
                    title: STResourcesStrings.Localizable.settingsOptionEmailLanguage
                ) {
                    SettingSelectableList(EmailLanguage.self, selected: language) {
                        language = $0
                    }
                }
            }
            .padding(.vertical, value: .medium)
            .padding(.horizontal, value: .large)
            .frame(maxWidth: .infinity)
            .background(
                Color.ST.cardBackground
                    .clipShape(.rect(cornerRadius: IKRadius.large))
            )
            .sheet(isPresented: $showPasswordSetting) {
                PasswordSettingView()
            }
        }
    }

    private func settingItem(setting: SettingItemIdentifier) -> SettingItem {
        let appSettings: AppSettings? = self.appSettings.value
        return setting.item(for: appSettings)
    }
}

#Preview {
    NewTransferSettingsView()
}
