/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2024 Infomaniak Network SA

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
import InfomaniakDI
import STCore

public actor AccountManager {
    @LazyInjectService private var injection: SwissTransferInjection

    /// In case we later choose to support multi account / login we simulate an existing guest
    private static let guestUserId = -1
    public typealias UserId = Int

    private var managers = [UserId: TransferManager]()

    init() {}

    public func createAndSetCurrentAccount() {
        UserDefaults.shared.currentUserId = AccountManager.guestUserId
    }

    public func getManager(userId: UserId) async -> TransferManager? {
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        assert(userId == AccountManager.guestUserId, "Only guest user is supported")
        if let manager = managers[userId] {
            return manager
        } else {
            try? await injection.accountManager.loadUser(userId: Int32(userId))
            managers[userId] = injection.transferManager
            return managers[userId]
        }
    }

    public func getCurrentManager() async -> TransferManager? {
        let currentUserId = UserDefaults.shared.currentUserId
        guard currentUserId != 0 else {
            return nil
        }

        assert(currentUserId == AccountManager.guestUserId, "Only guest user is supported")
        return await getManager(userId: currentUserId)
    }
}
