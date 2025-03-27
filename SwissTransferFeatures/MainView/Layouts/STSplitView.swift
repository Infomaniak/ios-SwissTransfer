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
import STReceivedView
import STSentView
import STSettingsView
import STTransferDetailsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct STSplitView: View {
    @EnvironmentObject private var mainViewState: MainViewState

    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedItems = [ImportedItem]()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(STTab.allCases, selection: $mainViewState.selectedTab) { tab in
                NavigationLink(value: tab) {
                    tab.label
                }
            }
            .stIconNavigationBar()
            .stContentMargins(.top, value: IKPadding.medium, safeAreaValue: IKPadding.mini)
            .safeAreaInset(edge: .bottom) {
                SidebarNewTransferButton(selection: $selectedItems)
                    .padding(value: .medium)
                    .onChange(of: selectedItems) { newSelectedItems in
                        mainViewState.newTransferContainer = NewTransferContainer(importedItems: newSelectedItems)
                    }
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
    let tab: STTab

    var body: some View {
        switch tab {
        case .sentTransfers:
            SentView()
        case .receivedTransfers:
            ReceivedView()
        case .settings:
            SettingsView()
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
