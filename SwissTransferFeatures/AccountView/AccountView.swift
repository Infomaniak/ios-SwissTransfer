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

import DesignSystem
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreUIResources
import STOnboardingView
import STResources
import STSettingsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct AccountView: View {
    @Environment(\.currentUser) private var currentUser

    @EnvironmentObject private var mainViewState: MainViewState

    @State private var isShowingLogoutView = false

    public init() {}

    public var body: some View {
        List {
            AccountHeaderView()

            Section {
                if currentUser != nil {
                    NavigationLink {} label: { // TODO: Change Navigation
                        SingleLabelSettingsCell(
                            title: STResourcesStrings.Localizable.settingsSwitchAccount,
                            leadingIcon: STResourcesAsset.Images.userChange
                        )
                    }
                    .settingsCell()
                } else {
                    Button {
                        mainViewState.isShowingLoginView = true
                    } label: {
                        SingleLabelSettingsCell(
                            title: STResourcesStrings.Localizable.settingsSignIn,
                            leadingIcon: STResourcesAsset.Images.user
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .settingsCell()
                }

                NavigationLink {
                    SettingsView()
                        .stNavigationTitle(STResourcesStrings.Localizable.settingsTitle)
                        .stNavigationBarStyle()
                } label: {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsTitle,
                                            leadingIcon: STResourcesAsset.Images.cog)
                }
                .settingsCell()

                Link(destination: SettingLinks.helpAndSupport) {
                    SingleLabelSettingsCell(
                        title: STResourcesStrings.Localizable.settingsHelpAndSupport,
                        leadingIcon: STResourcesAsset.Images.help, trailingIcon: STResourcesAsset.Images.export
                    )
                }
                .settingsCell()

                if let currentUser {
                    Button {
                        isShowingLogoutView = true
                    } label: {
                        SingleLabelSettingsCell(
                            title: STResourcesStrings.Localizable.settingsLogOut,
                            leadingIcon: STResourcesAsset.Images.logout
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .stCustomAlert(isPresented: $isShowingLogoutView) {
                        LogoutConfirmationView(user: currentUser)
                    }
                    .settingsCell()
                }
            }

            Section(header: Text(STResourcesStrings.Localizable.settingsCategoryAbout)) {
                Link(destination: SettingLinks.termsAndConditions) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionTermsAndConditions,
                                            trailingIcon: STResourcesAsset.Images.export)
                }
                .settingsCell()

                Link(destination: SettingLinks.discoverInfomaniak) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionDiscoverInfomaniak,
                                            trailingIcon: STResourcesAsset.Images.export)
                }
                .settingsCell()

                Link(destination: SettingLinks.shareYourIdeas) {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionShareIdeas,
                                            trailingIcon: STResourcesAsset.Images.export)
                }
                .settingsCell()

                if !Bundle.main.isRunningInTestFlight {
                    Link(destination: SettingLinks.appStoreReviewURL) {
                        SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsOptionGiveFeedback,
                                                trailingIcon: STResourcesAsset.Images.export)
                    }
                    .settingsCell()

                    Link(destination: UpdateLink.testFlight) {
                        SingleLabelSettingsCell(title: CoreUILocalizable.joinTheBetaButton,
                                                trailingIcon: STResourcesAsset.Images.export)
                    }
                    .settingsCell()
                }

                AboutSettingsCell(title: STResourcesStrings.Localizable.version,
                                  subtitle: CorePlatform.appVersionLabel(fallbackAppName: "SwissTransfer"))
                    .settingsCell()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appBackground()
        .fullScreenCover(isPresented: $mainViewState.isShowingLoginView) {
            SingleOnboardingView()
        }
    }
}

#Preview {
    AccountView()
}
