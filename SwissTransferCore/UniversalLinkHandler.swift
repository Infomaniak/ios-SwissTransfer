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

    private func createAccountIfNeeded() async -> TransferManager? {
        @InjectService var accountManager: AccountManager

        var defaultTransferManager = await accountManager.getCurrentManager()

        if defaultTransferManager == nil {
            await accountManager.createAndSetCurrentAccount()
            defaultTransferManager = await accountManager.getCurrentManager()
        }

        return defaultTransferManager
    }

    public func handlePossibleImportURL(_ url: URL) async -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard components?.path == "/import",
              let localSessionUUID = components?.queryItems?.first(where: { $0.name == "uuid" })?.value
        else {
            return nil
        }

        var defaultTransferManager = await createAccountIfNeeded()

        return localSessionUUID
    }

    public func handlePossibleTransferURL(_ url: URL) async -> UniversalLinkResult? {
        var defaultTransferManager = await createAccountIfNeeded()

        do {
            guard let transferUUID = try await defaultTransferManager?.addTransferByUrl(url: url.path, password: nil),
                  let transfer = try await defaultTransferManager?.getTransferByUUID(transferUUID: transferUUID)
            else { return nil }

            return UniversalLinkResult(link: url, result: .success(transfer))
        } catch {
            return UniversalLinkResult(link: url, result: .failure(error))
        }
    }
}

public struct UniversalLinkResult: Identifiable, Equatable, Sendable {
    public var id: String { link.absoluteString }
    public let link: URL
    public let result: Result<TransferUi, Error>

    public init(link: URL, result: Result<TransferUi, Error>) {
        self.link = link
        self.result = result
    }

    public static func == (lhs: UniversalLinkResult, rhs: UniversalLinkResult) -> Bool {
        return lhs.id == rhs.id
    }
}
