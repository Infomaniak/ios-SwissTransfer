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

import STCore
import SwiftUI
import SwissTransferCore

public final class MainViewState: ObservableObject {
    @Published public var selectedTab: STTab? = .sentTransfers
    @Published public var paths = [STTab: [NavigationDestination]]()

    @Published public var newTransferContainer: NewTransferContainer?

    public var selectedDestination: NavigationDestination? {
        get {
            guard let selectedTab else { return nil }
            return paths[selectedTab]?.last
        }
        set {
            guard let selectedTab else { return }
            if let newValue {
                paths[selectedTab] = [newValue]
            } else {
                paths[selectedTab] = []
            }
        }
    }

    public var selectedTransfer: TransferUi? {
        get {
            guard case .transfer(let transfer) = selectedDestination else { return nil }
            return transfer
        }
        set {
            guard let newValue else { return }
            selectedDestination = .transfer(newValue)
        }
    }

    public let transferManager: TransferManager

    public init(transferManager: TransferManager) {
        self.transferManager = transferManager
    }
}
