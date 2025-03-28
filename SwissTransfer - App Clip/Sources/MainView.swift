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

import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STDeepLinkPasswordView
import StoreKit
import STReceivedView
import STResources
import STTransferDetailsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct MainView: View {
    @LazyInjectService private var injection: SwissTransferInjection

    @EnvironmentObject private var mainViewState: MainViewState
    @EnvironmentObject private var universalLinksState: UniversalLinksState

    @State private var isShowingAppOverlay = false

    var body: some View {
        NavigationStack {
            ReceivedView()
                .appStoreOverlay(isPresented: $isShowingAppOverlay,
                                 configuration: { SKOverlay.AppConfiguration(appIdentifier: "6737686335", position: .bottom) })
                .stIconNavigationBar()
                .fullScreenCover(item: $mainViewState.selectedFullscreenTransfer) {
                    isShowingAppOverlay = true
                } content: { transferData in
                    TransferDetailsRootView(data: transferData)
                }
        }
        .sceneLifecycle(willEnterForeground: willEnterForeground)
        .environmentObject(mainViewState.transferManager)
        .onChange(of: universalLinksState.linkedTransfer) { linkedTransfer in
            guard let linkedTransfer else { return }

            mainViewState.handleDeepLink(linkedTransfer)
            universalLinksState.linkedTransfer = nil
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
