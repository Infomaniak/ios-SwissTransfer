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

import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct EditSettingView<T: SettingSelectable>: View {
    @EnvironmentObject private var mainViewState: MainViewState

    let title: String
    let section: String
    let items: [T]
    let selected: T
    let onSelection: (T) async -> Void

    public init(_ type: T.Type, selected: T, title: String, section: String, onSelection: @escaping (T) async -> Void) {
        items = Array(type.allCases)
        self.selected = selected
        self.title = title
        self.section = section
        self.onSelection = onSelection
    }

    var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            Section(header: Text(section)) {
                ForEach(items, id: \.self) { item in
                    EditSettingCell(selected: item == selected,
                                    label: item.title,
                                    leftImage: item.leftImage) {
                        action(item)
                    }
                }
            }
        }
        .stNavigationBarStyle()
        .stNavigationBar(title: title)
    }

    private func action(_ item: T) {
        Task {
            await onSelection(item)
        }
    }
}

#Preview {
    EditSettingView(Theme.self, selected: .dark, title: "Title", section: "Section") { theme in
        print("selected \(theme)")
    }
}
