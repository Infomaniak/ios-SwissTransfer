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
import STCore
import UserNotifications

@MainActor
public final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @LazyInjectService var accountManager: AccountManagerable

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

    public func handlePossibleTransfer(uuid: String) async -> TransferUi? {
        guard let defaultTransferManager = await accountManager.getCurrentManager() else { return nil }

        return try? await defaultTransferManager.getTransferByUUID(transferUUID: uuid)
    }
}
