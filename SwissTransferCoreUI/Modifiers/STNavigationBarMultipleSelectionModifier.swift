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

import STResources
import SwiftUI
import SwissTransferCore

struct STNavigationBarMultipleSelectionModifier: ViewModifier {
    @Environment(\.dismissModal) private var dismiss
    @EnvironmentObject private var multipleSelectionManager: MultipleSelectionManager

    let title: String
    let showCloseButton: Bool
    let closeButtonPlacement: ToolbarItemPlacement
    let isSelectAllEnabled: Bool
    let onSelectAll: () -> Void

    private var navigationTitle: String {
        multipleSelectionManager.isEnabled ? STResourcesStrings.Localizable
            .multipleSelectionTitle(multipleSelectionManager.selectedItems.count) : title
    }

    init(
        title: String,
        showCloseButton: Bool,
        closeButtonPlacement: ToolbarItemPlacement = .cancellationAction,
        isSelectAllEnabled: Bool,
        onSelectAll: @escaping () -> Void
    ) {
        self.title = title
        self.showCloseButton = showCloseButton
        self.closeButtonPlacement = closeButtonPlacement
        self.isSelectAllEnabled = isSelectAllEnabled
        self.onSelectAll = onSelectAll
    }

    func body(content: Content) -> some View {
        content
            .stNavigationTitle(navigationTitle)
            .toolbar {
                if multipleSelectionManager.isEnabled {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            multipleSelectionManager.disable()
                        } label: {
                            Text(STResourcesStrings.Localizable.buttonCancel)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onSelectAll()
                        } label: {
                            Text(STResourcesStrings.Localizable.buttonAll)
                        }
                        .disabled(!isSelectAllEnabled)
                    }
                } else if showCloseButton {
                    ToolbarItem(placement: closeButtonPlacement) {
                        ToolbarCloseButton(completion: dismiss)
                    }
                }
            }
            .navigationBarBackButtonHidden(multipleSelectionManager.isEnabled)
    }
}

public extension View {
    func stNavigationBarMultipleSelection(
        title: String,
        showCloseButton: Bool = true,
        closeButtonPlacement: ToolbarItemPlacement = .cancellationAction,
        isSelectAllEnabled: Bool,
        onSelectAll: @escaping () -> Void
    ) -> some View {
        modifier(
            STNavigationBarMultipleSelectionModifier(
                title: title,
                showCloseButton: showCloseButton,
                closeButtonPlacement: closeButtonPlacement,
                isSelectAllEnabled: isSelectAllEnabled,
                onSelectAll: onSelectAll
            )
        )
    }
}
