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
import SwiftUI
import SwissTransferCore

public enum RootViewType: Equatable {
    public static func == (lhs: RootViewType, rhs: RootViewType) -> Bool {
        switch (lhs, rhs) {
        case (.onboarding, .onboarding):
            return true
        case (.preloading, .preloading):
            return true
        case (.mainView(let lhsMainViewState, let lhsUser), .mainView(let rhsMainViewState, let rhsUser)):
            return lhsUser?.id == rhsUser?.id && lhsMainViewState.transferManager == rhsMainViewState.transferManager
        case (.updateRequired, .updateRequired):
            return true
        default:
            return false
        }
    }

    case mainView(MainViewState, UserProfile?)
    case preloading
    case onboarding
    case updateRequired
}

@MainActor
public final class RootViewState: ObservableObject {
    @Published public var state: RootViewType = .preloading

    public init() {}

    public func transitionToMainViewIfPossible(accountManager: AccountManager, rootViewState: RootViewState) async {
        if let currentManager = await accountManager.getCurrentManager() {
            rootViewState.state = .mainView(MainViewState(transferManager: currentManager), nil)
        } else {
            rootViewState.state = .onboarding
        }
    }
}
