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

import SwissTransferCore
import SwissTransferCoreUI
import SwiftUI
import STResources
import STSentView
import STReceivedView
import STSettingsView
import STTransferDetailsView

struct STSplitView: View {
    @EnvironmentObject private var mainViewState: MainViewState

    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(STTab.allCases, selection: $mainViewState.selectedTab) { tab in
                NavigationLink(value: tab) {
                    tab.label
                }
            }
            .stIconNavigationBar()
        } content: {
            if let selectedTab = mainViewState.selectedTab {
                ContentSplitView(tab: selectedTab)
            }
        } detail: {
            if let selectedTab = mainViewState.selectedTab {
                DetailSplitView(tab: selectedTab, path: mainViewState.paths[selectedTab])
            }
        }
        .navigationSplitViewStyle(.balanced)
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
    let tab: STTab
    let path: [STDestination]?

    var body: some View {
        if let lastDestination = path?.last {
            switch lastDestination {
            case .transfer(let transfer):
                TransferDetailsView(transfer: transfer)
            case .settings:
                Text("Settings Option.")
            }
        } else {
            Text("No Item Selected.")
        }
    }
}

#Preview {
    STSplitView()
}
