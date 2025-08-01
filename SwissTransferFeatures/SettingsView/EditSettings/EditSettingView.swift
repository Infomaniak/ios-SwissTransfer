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

import InfomaniakCoreCommonUI
import InfomaniakDI
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct EditSettingView<T: SettingSelectable>: View {
    @EnvironmentObject private var mainViewState: MainViewState

    let title: String
    let section: String
    let items: [T]
    let selected: T
    let matomoScreen: MatomoScreen

    public init(
        _ type: T.Type,
        selected: T,
        title: String,
        section: String,
        matomoScreen: MatomoScreen,
    ) {
        items = Array(type.allCases)
        self.selected = selected
        self.title = title
        self.section = section
        self.matomoScreen = matomoScreen
    }

    var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            Section(header: Text(section)) {
                if let category = T.matomoCategoryGlobal {
                    ForEach(items, id: \.self) { item in
                        EditSettingCell(selected: item == selected,
                                        label: item.title,
                                        leftImage: item.leftImage,
                                        matomoCategory: category,
                                        matomoName: item.matomoName) {
                            action(item)
                        }
                        .settingsCell()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .appBackground()
        .stNavigationBarStyle()
        .stNavigationTitle(title)
        .matomoView(view: matomoScreen)
    }

    private func action(_ item: T) {
        Task {
            await item.setSelected()
        }
    }
}

#Preview {
    EditSettingView(
        Theme.self,
        selected: .dark,
        title: "Title",
        section: "Section",
        matomoScreen: .themeSetting
    )
}
