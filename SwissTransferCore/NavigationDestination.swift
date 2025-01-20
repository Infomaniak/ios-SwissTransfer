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
import STCore

public enum TransferState {
    case ready
    case expired
    case waitVirusCheck
    case virusFlagged
}

public struct TransferData: Identifiable {
    public let id = UUID()
    public let transfer: TransferUi?
    public let state: TransferState?

    public init(transfer: TransferUi) {
        self.transfer = transfer
        state = nil
    }

    public init(state: TransferState) {
        transfer = nil
        self.state = state
    }
}

public enum NavigationDestination: Hashable {
    case transfer(TransferData)
    case settings(SettingDetailUI)

    public static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.transfer(let leftTransfer), .transfer(let rightTransfer)):
            return leftTransfer.id == rightTransfer.id
        case (.settings(let leftSetting), .settings(let rightSetting)):
            return leftSetting.hashValue == rightSetting.hashValue
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .transfer(let transfer):
            hasher.combine(transfer.id)
        case .settings(let setting):
            hasher.combine(setting.hashValue)
        }
    }
}
