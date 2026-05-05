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
import InfomaniakCore
@preconcurrency import STCore

public struct UserSession: Sendable {
    public let userId: AccountManager.UserId
    public let userProfile: UserProfile?

    public var transferManager: TransferManager {
        return swissTransferManager.transferManager
    }

    public let swissTransferManager: SwissTransferInjection

    public var isGuest: Bool {
        userId == AccountManager.guestUserId
    }

    init(userId: AccountManager.UserId, userProfile: UserProfile?, swissTransferManager: SwissTransferInjection) {
        self.userId = userId
        self.userProfile = userProfile
        self.swissTransferManager = swissTransferManager
    }
}
