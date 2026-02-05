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
import InfomaniakCoreUIResources
import InfomaniakDI
import InterAppLogin
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct OnboardingBottomButtonsView: View {
    @InjectService private var accountManager: AccountManagerable
    @InjectService private var connectedAccountsManager: ConnectedAccountManagerable

    @EnvironmentObject private var rootViewState: RootViewState

    @ObservedObject var loginHandler = LoginHandler()

    @State private var excludedUserIds: [AccountManager.UserId] = []
    @State private var isPresentingInterAppLogin = false

    @Binding var selection: Int

    let slideCount: Int

    private var isLastSlide: Bool {
        return selection == slideCount - 1
    }

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            if !isPresentingInterAppLogin {
                Button(STResourcesStrings.Localizable.buttonStart) {
                    Task {
                        await accountManager.createAndSetCurrentAccount()
                        if let currentManager = await accountManager.getCurrentManager() {
                            rootViewState.state = .mainView(MainViewState(transferManager: currentManager))
                        }
                    }
                }
                .buttonStyle(.ikBorderedProminent)
            } else {
                ContinueWithAccountView(
                    isLoading: loginHandler.isLoading) {
                        loginPressed()
                    } onLoginWithAccountsPressed: { accounts in
                        loginWithAccountsPressed(accounts: accounts)
                    } onCreateAccountPressed: { /* Empty on purpose */ }
            }
        }
        .ikButtonFullWidth(true)
        .controlSize(.large)
        .opacity(isLastSlide ? 1 : 0)
        .overlay {
            if !isLastSlide {
                Button {
                    selection += 1
                } label: {
                    Label {
                        Text(CoreUILocalizable.buttonNext)
                    } icon: {
                        STResourcesAsset.Images.arrowRight.swiftUIImage
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.ikSquare)
            }
        }
        .padding(.horizontal, value: .medium)
        .task {
            excludedUserIds = await accountManager.getAccountIds()
            let accounts = await connectedAccountsManager.listAllLocalAccounts()
            if !accounts.isEmpty {
                isPresentingInterAppLogin = true
            }
        }
    }

    private func loginPressed() {
        Task {
            await loginHandler.login()
        }
    }

    private func openGuestSession() {
        Task {
            await accountManager.createAndSetCurrentAccount()
            if let currentManager = await accountManager.getCurrentManager() {
                rootViewState.state = .mainView(MainViewState(transferManager: currentManager))
            }
        }
    }

    private func loginWithAccountsPressed(accounts: [ConnectedAccount]) {
        Task {
            await loginHandler.loginWith(accounts: accounts)
        }
    }
}

#Preview {
    OnboardingBottomButtonsView(selection: .constant(1), slideCount: 3)
}
