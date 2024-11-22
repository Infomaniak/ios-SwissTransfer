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
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct NewTransferSettingsView: View {
    @State private var showPasswordSetting = false
    @State private var isShowingValiditySetting = false
    @State private var isShowingDownloadLimitSetting = false
    @State private var isShowingLanguageSetting = false

    @Binding var duration: ValidityPeriod
    @Binding var limit: DownloadLimit
    @Binding var language: EmailLanguage
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Text(STResourcesStrings.Localizable.advancedSettingsTitle)
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textPrimary)

            VStack(alignment: .leading, spacing: IKPadding.medium) {
                NewTransferSettingCell(
                    title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
                    icon: STResourcesAsset.Images.clock.swiftUIImage,
                    value: duration.title
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

                NewTransferSettingCell(
                    title: STResourcesStrings.Localizable.settingsOptionDownloadLimit,
                    icon: STResourcesAsset.Images.fileDownload.swiftUIImage,
                    value: limit.title
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

                NewTransferSettingCell(
                    title: STResourcesStrings.Localizable.settingsOptionPassword,
                    icon: STResourcesAsset.Images.textfieldLock.swiftUIImage,
                    value: STResourcesStrings.Localizable.settingsOptionNone
                ) {
                    showPasswordSetting = true
                }

                NewTransferSettingCell(
                    title: STResourcesStrings.Localizable.settingsOptionEmailLanguage,
                    icon: STResourcesAsset.Images.message.swiftUIImage,
                    value: language.title
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
                PasswordSettingView(password: $password)
            }
        }
    }
}

#Preview {
    NewTransferSettingsView(
        duration: .constant(.one),
        limit: .constant(.oneHundred),
        language: .constant(.french),
        password: .constant("")
    )
}
