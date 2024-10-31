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

import STResources
import SwiftUI
import SwissTransferCore

struct STNavigationBarNewTransferModifier: ViewModifier {
    @Environment(\.dismissModal) private var dismissModal

    let title: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.ST.title2)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        dismissModal()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
    }
}

public extension View {
    func stNavigationBarNewTransfer(title: String = "Transfer") -> some View {
        modifier(STNavigationBarNewTransferModifier(title: title))
    }
}
