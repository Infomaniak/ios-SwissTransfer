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
import Sentry
import STCore

public struct UniversalLinkHandler {
    public enum UniversalLinkType {
        case importTransferFromExtension(uuid: String)
        case openTransfer(linkedTransfer: UniversalLinkResult)
        case deleteTransfer(linkedDeleteTransfer: DeleteTransferLinkResult)
    }

    public init() {}

    public func handlePossibleUniversalLink(url: URL) async -> UniversalLinkType? {
        addReceivedUniversalLinkBreadcrumb()

        guard let deepLinkType = DeepLinkType.companion.fromURL(url: url.absoluteString) else {
            return nil
        }

        let defaultTransferManager = await createAccountIfNeeded()

        if let importTransferFromExtension = deepLinkType as? DeepLinkType.ImportTransferFromExtension {
            return .importTransferFromExtension(uuid: importTransferFromExtension.uuid)
        }
        if deepLinkType is DeepLinkType.OpenTransfer {
            guard let linkedTransfer = await handleTransferDeepLink(url: url, transferManager: defaultTransferManager) else {
                return nil
            }
            return .openTransfer(linkedTransfer: linkedTransfer)
        }
        if let deleteTransfer = deepLinkType as? DeepLinkType.DeleteTransfer {
            let linkedDeleteTransfer = DeleteTransferLinkResult(uuid: deleteTransfer.uuid, token: deleteTransfer.token)
            return .deleteTransfer(linkedDeleteTransfer: linkedDeleteTransfer)
        }
        return nil
    }

    private func handleTransferDeepLink(url: URL, transferManager: TransferManager?) async -> UniversalLinkResult? {
        guard let transferManager else { return nil }

        do {
            guard let transferUUID = try await transferManager.addTransferByUrl(url: url.path, password: nil),
                  let transfer = try await transferManager.getTransferByUUID(transferUUID: transferUUID)
            else { return nil }

            return UniversalLinkResult(link: url, result: .success(transfer))
        } catch {
            return UniversalLinkResult(link: url, result: .failure(error))
        }
    }

    private func createAccountIfNeeded() async -> TransferManager? {
        @InjectService var accountManager: AccountManagerable

        var defaultTransferManager = await accountManager.getCurrentManager()

        if defaultTransferManager == nil {
            await accountManager.createAndSetCurrentAccount()
            defaultTransferManager = await accountManager.getCurrentManager()
        }

        return defaultTransferManager
    }

    private func addReceivedUniversalLinkBreadcrumb() {
        let crumb = Breadcrumb(level: .info, category: "UniversalLink")
        crumb.type = "info"
        crumb.message = "App received Universal Link"

        SentrySDK.addBreadcrumb(crumb)
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

public struct DeleteTransferLinkResult: Identifiable, Equatable, Sendable {
    public var id: String {
        return uuid
    }

    public let uuid: String
    public let token: String

    public init(uuid: String, token: String) {
        self.uuid = uuid
        self.token = token
    }
}
