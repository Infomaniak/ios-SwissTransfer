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
import STOnboardingView
import STResources
import STSettingsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct AccountListView: View {
    @Environment(\.currentUser) private var currentUser

    @EnvironmentObject private var mainViewState: MainViewState

    @State private var isShowingNewAccountView = false
    @State private var users: [UserProfile] = []

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: IKPadding.micro) {
                ForEach(users, id: \.id) { user in
                    AccountCellView(
                        selectedUserId: .constant(currentUser?.id),
                        user: user
                    )
                }
            }

            DividerView()
                .padding(.vertical, value: .mini)

            Button {
                mainViewState.isShowingLoginView = true
            } label: {
                SingleLabelSettingsCell(
                    title: STResourcesStrings.Localizable.buttonUseOtherAccount,
                    leadingIcon: STResourcesAsset.Images.userAdd
                )
                .settingsCell()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, value: .medium)
        .task {
            try? await updateUsers()
        }
        .fullScreenCover(isPresented: $mainViewState.isShowingLoginView) {
            SingleOnboardingView()
        }
    }

    private func updateUsers() async throws {
        // TODO: Update func
        await withThrowingTaskGroup(of: Void.self) { group in
            users = [currentUser!]
        }
    }
}

#Preview {
    AccountListView()
}
