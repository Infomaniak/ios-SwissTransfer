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
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STResources
import STSettingsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct AccountListView: View {
    @Environment(\.currentUser) private var currentUser

    @EnvironmentObject private var mainViewState: MainViewState

    @State private var users: [UserProfile]?

    let userCount: Int

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: IKPadding.micro) {
                if let users {
                    ForEach(users, id: \.id) { user in
                        AccountCellView(selectedUserId: currentUser?.id, user: user)
                    }
                } else {
                    ForEach(0 ..< userCount, id: \.self) { _ in
                        AccountCellPlaceholderView()
                            .padding(.horizontal, value: .medium)
                    }
                    .task {
                        try? await updateUsers()
                    }
                }
            }

            DividerView()
                .padding(.vertical, value: .mini)

            Button {
                @InjectService var matomo: MatomoUtils
                matomo.track(eventWithCategory: .switchUserBottomSheet, name: .addAccount)

                mainViewState.isShowingLoginView = true
            } label: {
                SingleLabelSettingsCell(
                    title: STResourcesStrings.Localizable.buttonUseOtherAccount,
                    leadingIcon: STResourcesAsset.Images.userAdd
                )
            }
            .buttonStyle(.plain)
            .padding(value: .medium)
        }
        .padding(.horizontal, value: .medium)
    }

    private func updateUsers() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            @InjectService var accountManager: AccountManager
            @InjectService var tokenStore: TokenStore

            var storedUsers = [UserProfile]()
            let allTokens = tokenStore.getAllTokens()
            for (userId, token) in allTokens {
                if let user = await accountManager.userProfileStore.getUserProfile(id: userId) {
                    storedUsers.append(user)
                }

                group.addTask {
                    _ = try await accountManager.updateUser(token: token.apiToken)
                }
            }

            users = storedUsers
        }
    }
}

#Preview {
    AccountListView(userCount: 1)
}
