/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2024 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See them
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STRootTransferView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct MainView: View {
    @LazyInjectService private var injection: SwissTransferInjection

    @Environment(\.isCompactWindow) private var isCompactWindow

    @EnvironmentObject private var mainViewState: MainViewState
    @EnvironmentObject private var universalLinksState: UniversalLinksState
    @EnvironmentObject private var notificationCenterDelegate: NotificationCenterDelegate

    public init() {}

    public var body: some View {
        ZStack {
            if isCompactWindow {
                STTabView()
            } else {
                STSplitView()
            }
        }
        .sceneLifecycle(willEnterForeground: willEnterForeground)
        .environmentObject(mainViewState.transferManager)
        .onChange(of: universalLinksState.linkedTransfer) { linkedTransfer in
            guard let linkedTransfer else { return }

            mainViewState.handleDeepLink(linkedTransfer)
            universalLinksState.linkedTransfer = nil
        }
        .onChange(of: notificationCenterDelegate.tappedTransfer) { tappedTransfer in
            guard let tappedTransfer else { return }

            mainViewState.selectedTransfer = .transfer(tappedTransfer)
        }
        .task(id: isCompactWindow) {
            mainViewState.isSplitView = !isCompactWindow
        }
        .fullScreenCover(item: $mainViewState.newTransferContainer) { container in
            RootTransferView(initialItems: container.importedItems)
        }
        .sheet(item: $mainViewState.isShowingProtectedDeepLink) { identifiableURL in
            DeepLinkPasswordView(url: identifiableURL)
        }
    }

    private func willEnterForeground() {
        Task {
            try? await injection.transferManager.deleteExpiredTransfers()
        }
    }
}

#Preview {
    MainView()
}
