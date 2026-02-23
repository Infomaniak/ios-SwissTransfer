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

import Foundation
import InfomaniakDI
import InfomaniakLogin
import SwissTransferCore

@MainActor
final class SettingsAccountManagementViewDelegate: ObservableObject, @MainActor DeleteAccountDelegate {
    @Published var resultMessage: String?

    func didCompleteDeleteAccount() {
        Task {
            @InjectService var accountManager: AccountManager

            guard let userSession = await accountManager.getCurrentUserSession() else { return }
            await accountManager.removeTokenAndAccountFor(userId: userSession.userId)
            // TODO: Switch to next available account
            resultMessage = "Delete account success" // TODO: Localize
        }
    }

    func didFailDeleteAccount(error _: InfomaniakLoginError) {
        resultMessage = "Failed to delete account" // TODO: Localize
    }
}
