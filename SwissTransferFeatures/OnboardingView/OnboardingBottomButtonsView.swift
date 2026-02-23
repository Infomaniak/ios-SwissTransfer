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
import InfomaniakCreateAccount
import InfomaniakDI
import InterAppLogin
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct OnboardingBottomButtonsView: View {
    @InjectService private var accountManager: AccountManager
    @InjectService private var connectedAccountsManager: ConnectedAccountManagerable

    @EnvironmentObject private var rootViewState: RootViewState

    @ObservedObject var loginHandler: LoginHandler

    @State private var excludedUserIds: [AccountManager.UserId] = []
    @State private var isPresentingInterAppLogin: Bool
    @State private var isPresentingCreateAccount = false

    @Binding var selection: Int

    let slideCount: Int

    init(
        loginHandler: LoginHandler,
        isPresentingInterAppLogin: Bool = false,
        selection: Binding<Int>,
        slideCount: Int
    ) {
        self.loginHandler = loginHandler
        _isPresentingInterAppLogin = State(initialValue: isPresentingInterAppLogin)
        _selection = selection
        self.slideCount = slideCount
    }

    private var isLastSlide: Bool {
        return selection == slideCount - 1
    }

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            if !isPresentingInterAppLogin {
                Button(STResourcesStrings.Localizable.buttonStart, action: openGuestSession)
                    .buttonStyle(.ikBorderedProminent)
            } else {
                ContinueWithAccountView(
                    isLoading: loginHandler.isLoading,
                    excludingUserIds: excludedUserIds,
                    allowsMultipleSelection: false
                ) {
                    loginPressed()
                } onLoginWithAccountsPressed: { accounts in
                    loginWithAccountsPressed(accounts: accounts)
                } onCreateAccountPressed: {
                    isPresentingCreateAccount = true
                }
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
        .sheet(isPresented: $isPresentingCreateAccount) {
            RegisterView(registrationProcess: .swissTransfer) { viewController in
                guard let viewController else { return }
                loginHandler.loginAfterAccountCreation(from: viewController)
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
            if let injection = await accountManager.getCurrentUserSession()?.swissTransferManager {
                rootViewState.state = .mainView(MainViewState(swissTransferManager: injection), nil)
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
    OnboardingBottomButtonsView(loginHandler: LoginHandler(), selection: .constant(1), slideCount: 3)
}
