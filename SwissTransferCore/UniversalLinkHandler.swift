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
import InfomaniakDI
import OSLog
import STCore

public struct UniversalLinkHandler {
    public init() {}

    public func handlePossibleTransferURL(_ url: URL) async throws -> TransferUi? {
        @InjectService var accountManager: AccountManager

        var defaultTransferManager = await accountManager.getCurrentManager()

        if defaultTransferManager == nil {
            await accountManager.createAndSetCurrentAccount()
            defaultTransferManager = await accountManager.getCurrentManager()
        }

        guard let transferUUID = try await defaultTransferManager?.addTransferByUrl(url: url.path, password: nil) else {
            return nil
        }

        let transfer = try await defaultTransferManager?.getTransferByUUID(transferUUID: transferUUID)

        return transfer
    }
}
