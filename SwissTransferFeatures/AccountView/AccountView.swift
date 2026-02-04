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
import STResources
import STSettingsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

/// Links used in the settings view
public enum SettingLinks {
    public static let discoverInfomaniak = URL(string: STResourcesStrings.Localizable.urlAbout)!
    public static let shareYourIdeas = URL(string: STResourcesStrings.Localizable.urlUserReport)!
    public static let githubRepository = URL(string: "https://github.com/Infomaniak/ios-SwissTransfer")!
    public static let termsAndConditions = URL(string: "https://www.swisstransfer.com/?cgu")!
    public static let appStoreReviewURL = URL(string: "https://apps.apple.com/app/id6737686335?action=write-review")!
    public static let helpAndSupport = URL(string: "https://support.infomaniak.com")!
}

public struct AccountView: View {
    let user: UserProfile?
    @State private var isShowingLogoutView = false

    public init(user: UserProfile? = nil) {
        self.user = user
    }

    public var body: some View {
        List {
            AccountHeaderView(user: PreviewHelper.sampleUser)
                .frame(maxWidth: .infinity)

            Section {
                if user != nil {
                    NavigationLink {} label: { // TODO: Change Navigation
                        SingleLabelSettingsCell(
                            title: "Changer de compte", // TODO: Import or create trad
                            leadingIcon: STResourcesAsset.Images.userChange
                        )
                    }
                    .settingsCell()
                } else {
                    NavigationLink {} label: { // TODO: Change Navigation
                        SingleLabelSettingsCell(
                            title: "Connexion", // TODO: Import or create trad
                            leadingIcon: STResourcesAsset.Images.user
                        )
                    }
                    .settingsCell()
                }

                NavigationLink {
                    SettingsView()
                        .stNavigationTitle(STResourcesStrings.Localizable.settingsTitle)
                        .stNavigationBarStyle()
                } label: {
                    SingleLabelSettingsCell(title: STResourcesStrings.Localizable.settingsTitle,
                                            leadingIcon: STResourcesAsset.Images.cog)
                }.settingsCell()

                Link(destination: SettingLinks.helpAndSupport) {
                    SingleLabelSettingsCell(
                        title: "Aide et support", // TODO: Import or create trad
                        leadingIcon: STResourcesAsset.Images.help, trailingIcon: STResourcesAsset.Images.export
                    )
                }
                .settingsCell()

                if let user = user {
                    Button {
                        isShowingLogoutView = true
                    } label: {
                        SingleLabelSettingsCell(
                            title: "Se déconnecter", // TODO: Import or create trad
                            leadingIcon: STResourcesAsset.Images.logout
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .stCustomAlert(isPresented: $isShowingLogoutView) {
                        LogoutConfirmationView(user: user)
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
    }
}

#Preview {
    AccountView()
}
