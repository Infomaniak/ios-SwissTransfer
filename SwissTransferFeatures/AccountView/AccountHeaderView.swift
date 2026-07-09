/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct AccountHeaderView: View {
    @Environment(\.currentUser) private var currentUser
    @EnvironmentObject private var mainViewState: MainViewState
    @InjectService private var accountManager: SwissTransferCore.AccountManager

    @State private var selectedOrganization: STDOrganizationAccount?
    @State private var organizations = [STDOrganizationAccount]()

    public var body: some View {
        VStack(spacing: IKPadding.micro) {
            if let currentUser {
                AvatarView(user: currentUser)
            } else {
                STResourcesAsset.Images.user.swiftUIImage
                    .foregroundStyle(Color.ST.onRecipientLabelBackground)
                    .frame(width: 80, height: 80)
                    .background(Color.ST.highlighted, in: .circle)
                    .padding(IKPadding.small)
            }

            Text(currentUser?.displayName ?? STResourcesStrings.Localizable.titleMyAccount(1))
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)
                .multilineTextAlignment(.center)

            if let currentUser {
                Text(currentUser.email)
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let selectedOrganization {
                Button {
                    mainViewState.isShowingSwitchOrgaListView = true
                } label: {
                    HStack(spacing: IKPadding.mini) {
                        STResourcesAsset.Images.building.swiftUIImage
                            .iconSize(.medium)

                        Text(selectedOrganization.name)
                            .multilineTextAlignment(.center)

                        STResourcesAsset.Images.synchronize.swiftUIImage
                            .iconSize(.medium)
                    }
                }
                .foregroundStyle(Color.ST.textPrimary)
                .buttonStyle(.plain)
                .padding(.top, value: .micro)
                .stFloatingPanel(isPresented: $mainViewState.isShowingSwitchOrgaListView, title: "Change organization") {
                    OrgaListView(selectedOrganization: selectedOrganization, organizations: organizations)
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowSpacing(0)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .frame(maxWidth: .infinity)
        .task {
            guard let organizationAccounts = await accountManager.organizationAccounts() else { return }
            organizations = organizationAccounts
        }
        .task {
            guard let selectedOrganizationFlow: SkieSwiftOptionalFlow<STDOrganizationAccount> = await accountManager
                .selectedOrganizationId() else { return }

            for await value in selectedOrganizationFlow {
                selectedOrganization = value
            }
        }
    }
}

#Preview {
    AccountHeaderView()
}
