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

import DesignSystem
import InfomaniakCoreSwiftUI
import STAccountView
import STReceivedView
import STSentView
import STTransferDetailsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct STSplitView: View {
    @Environment(\.currentUser) private var currentUser
    @EnvironmentObject private var mainViewState: MainViewState

    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedItems = [ImportedItem]()
    @StateObject private var avatarLoader = AvatarImageLoader()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(STTab.allCases, selection: $mainViewState.selectedTab) { tab in
                NavigationLink(value: tab) {
                    tab.label(avatarImage: avatarLoader.loadedImage)
                }
            }
            .task {
                await avatarLoader.loadAvatar(from: currentUser?.avatar)
            }
            .stIconNavigationBar()
            .stContentMargins(.top, value: IKPadding.medium, safeAreaValue: IKPadding.mini)
            .safeAreaInset(edge: .bottom) {
                SidebarNewTransferButton(selection: $selectedItems, matomoCategory: .importFileFromSidebar)
                    .padding(value: .medium)
                    .onChangeOfSelectedItems($selectedItems)
            }
        } content: {
            if let selectedTab = mainViewState.selectedTab {
                ContentSplitView(tab: selectedTab)
                    .stNavigationBarStyle()
            }
        } detail: {
            DetailSplitView(destination: mainViewState.selectedDestination)
                .stNavigationBarStyle()
        }
    }
}

private struct ContentSplitView: View {
    @Environment(\.currentUser) private var currentUser

    @StateObject private var avatarLoader = AvatarImageLoader()

    let tab: STTab

    var body: some View {
        Group {
            switch tab {
            case .sentTransfers:
                SentView()
            case .receivedTransfers:
                ReceivedView()
            case .account:
                AccountView()
            }
        }
        .task {
            await avatarLoader.loadAvatar(from: currentUser?.avatar)
        }
    }
}

private struct DetailSplitView: View {
    let destination: NavigationDestination?

    var body: some View {
        if let destination {
            switch destination {
            case .transfer(let transferData):
                TransferDetailsRootView(data: transferData)
                    .id(transferData.id)
            case .settings:
                Text("TODO: Settings Option.")
            }
        } else {
            SplitViewDetailsEmptyView()
        }
    }
}

#Preview {
    STSplitView()
}
