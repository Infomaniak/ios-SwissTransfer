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

import STReceivedView
import STResources
import STSentView
import STSettingsView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct STTabView: View {
    @EnvironmentObject private var mainViewState: MainViewState

    var body: some View {
        TabView(selection: $mainViewState.selectedTab) {
            SentView()
                .navigableTab(.sentTransfers)
                .tabItem { STTab.sentTransfers.label }
                .tag(STTab.sentTransfers)

            ReceivedView()
                .navigableTab(.receivedTransfers)
                .tabItem { STTab.receivedTransfers.label }
                .tag(STTab.receivedTransfers)

            SettingsView()
                .navigableTab(.settings)
                .tabItem { STTab.settings.label }
                .tag(STTab.settings)
        }
    }
}
