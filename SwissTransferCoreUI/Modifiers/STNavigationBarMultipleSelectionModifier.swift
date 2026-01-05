/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

struct STNavigationBarMultipleSelectionModifier: ViewModifier {
    @Environment(\.dismissModal) private var dismiss

    @ObservedObject private var multipleSelectionViewModel: MultipleSelectionViewModel

    let title: String
    let showCloseButton: Bool

    init(title: String, showCloseButton: Bool, multipleSelectionViewModel: MultipleSelectionViewModel) {
        self.title = title
        self.showCloseButton = showCloseButton
        self.multipleSelectionViewModel = multipleSelectionViewModel
    }

    func body(content: Content) -> some View {
        if multipleSelectionViewModel.isEnabled {
            content
                .stNavigationTitle("1 sélectionné")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            multipleSelectionViewModel.disable()
                        } label: {
                            Text("Annuler")
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            multipleSelectionViewModel.toggleSelectAll.toggle()
                        } label: {
                            Text("Tout")
                        }
                    }
                }
        } else {
            content
                .stNavigationBarFullScreen(title: title, showCloseButton: showCloseButton)
        }
    }
}

public extension View {
    func stNavigationBarMultipleSelection(
        title: String = "Transfer",
        showCloseButton: Bool = true,
        multipleSelectionViewModel: MultipleSelectionViewModel
    ) -> some View {
        modifier(
            STNavigationBarMultipleSelectionModifier(
                title: title,
                showCloseButton: showCloseButton,
                multipleSelectionViewModel: multipleSelectionViewModel
            )
        )
    }
}
