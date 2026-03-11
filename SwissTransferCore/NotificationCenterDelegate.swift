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
import InAppTwoFactorAuthentication
@preconcurrency import InfomaniakCore
import InfomaniakDI
import STCore
import UIKit
import UserNotifications

@MainActor
public final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @LazyInjectService var accountManager: AccountManager

    @Published public var tappedTransfer: TransferUi?

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            guard let transferUUID = response.notification.request.content
                .userInfo[NotificationsHelper.UserInfoKeys.transferUUID] as? String else {
                return
            }

            tappedTransfer = await handlePossibleTransfer(uuid: transferUUID)
        default:
            break
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await handleTwoFactorAuthenticationNotification(notification)
        return []
    }

    func handlePossibleTransfer(uuid: String) async -> TransferUi? {
        guard let defaultTransferManager = await accountManager.getCurrentUserSession()?.transferManager else { return nil }

        return try? await defaultTransferManager.getTransferByUUID(transferUUID: uuid)
    }

    func handleTwoFactorAuthenticationNotification(_ notification: UNNotification) async {
        @InjectService var inAppTwoFactorAuthenticationManager: InAppTwoFactorAuthenticationManagerable

        guard let userId = inAppTwoFactorAuthenticationManager.handleRemoteNotification(notification) else {
            return
        }

        @InjectService var tokenStore: TokenStore
        let tokens = tokenStore.getAllTokens()

        guard !tokens.isEmpty else {
            UIApplication.shared.unregisterForRemoteNotifications()
            return
        }

        guard let token = tokens[userId],
              let user = await accountManager.userProfileStore.getUserProfile(id: userId) else {
            return
        }

        let apiFetcher = await accountManager.getApiFetcher(token: token.apiToken)

        let session = InAppTwoFactorAuthenticationSession(user: user, apiFetcher: apiFetcher)

        inAppTwoFactorAuthenticationManager.checkConnectionAttempts(using: session)
    }
}
