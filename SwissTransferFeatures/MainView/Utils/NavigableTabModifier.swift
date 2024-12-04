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

import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

// periphery:ignore - Used in navigableTab
struct NavigableTabModifier: ViewModifier {
    @EnvironmentObject private var mainViewState: MainViewState

    let tab: STTab

    func body(content: Content) -> some View {
        NavigationStack(path: binding(for: tab)) {
            content
                .stIconNavigationBar()
        }
    }

    private func binding(for tab: STTab) -> Binding<[NavigationDestination]> {
        return Binding {
            mainViewState.paths[tab, default: []]
        } set: { newValue, _ in
            mainViewState.paths[tab] = newValue
        }
    }
}

extension View {
    // periphery:ignore - Used in STTabModifier
    func navigableTab(_ tab: STTab) -> some View {
        modifier(NavigableTabModifier(tab: tab))
    }
}
