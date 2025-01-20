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

import OSLog
import STCore
import SwiftModalPresentation
import SwiftUI
import SwissTransferCore

public final class MainViewState: ObservableObject {
    @Published public var selectedTab: STTab? = .sentTransfers
    @Published public var paths = [STTab: [NavigationDestination]]()

    @Published public var newTransferContainer: NewTransferContainer?
    /// Only used by STTabView
    @Published public var selectedFullscreenTransfer: TransferData?

    public var isSplitView = false

    @ModalPublished public var isShowingProtectedDeepLink: IdentifiableURL?

    public var selectedDestination: NavigationDestination? {
        get {
            guard let selectedTab else { return nil }
            if isSplitView {
                return paths[selectedTab]?.last
            } else if let selectedFullscreenTransfer {
                return .transfer(selectedFullscreenTransfer)
            }
            return nil
        }
        set {
            guard let selectedTab else { return }
            guard let newValue else {
                paths[selectedTab] = []
                selectedFullscreenTransfer = nil
                return
            }

            if isSplitView {
                paths[selectedTab] = [newValue]
            } else if case .transfer(let newTransfer) = newValue {
                selectedFullscreenTransfer = newTransfer
            }
        }
    }

    public var selectedTransfer: TransferData? {
        get {
            guard case .transfer(let transfer) = selectedDestination else { return nil }
            return transfer
        }
        set {
            guard let newValue else { return }
            if let transfer = newValue.transfer {
                selectedTab = transfer.direction == .sent ? .sentTransfers : .receivedTransfers
            }
            selectedDestination = .transfer(newValue)
        }
    }

    public let transferManager: TransferManager

    public init(transferManager: TransferManager) {
        self.transferManager = transferManager
    }

    public func handleDeepLink(_ linkResult: UniversalLinkResult) {
        switch linkResult.result {
        case .success(let transfer):
            selectedTransfer = TransferData(transfer: transfer)
        case .failure(let error as NSError):
            let kotlinException = error.kotlinException
            if kotlinException is STNDeeplinkException.PasswordNeededDeeplinkException {
                isShowingProtectedDeepLink = IdentifiableURL(url: linkResult.link)
            } else if kotlinException is STNDeeplinkException.ExpiredDeeplinkException
                        || kotlinException is STNDeeplinkException.NotFoundDeeplinkException {
                selectedTransfer = TransferData(state: .expired)
            } else {
                // TODO: Need to handle Virus_check and virus_flagged exceptions
                Logger.deepLink.error("Unable to handle DeepLink: \(error.localizedDescription)")
            }
        }
    }
}
