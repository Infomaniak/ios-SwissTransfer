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
import Sentry
import STCore

public extension Notification.Name {
    static let userWasLoggedOut = Notification.Name("userWasLoggedOut")
}

final class UnauthorizedHandler: STNUnauthorizedHandler {
    func __onUnauthorized(userId: KotlinLong?) async throws {
        guard let userId = userId?.intValue else {
            return
        }

        SentrySDK.capture(message: "Received HTTP Status 401 Unauthorized")

        @InjectService var accountManager: AccountManager
        let isCurrentUser = await accountManager.currentUserId == userId
        await accountManager.removeAccountAndSwitchToNextUserIfNecessary(userId: userId)

        if isCurrentUser {
            NotificationCenter.default.post(name: .userWasLoggedOut, object: nil)
        }
    }
}
