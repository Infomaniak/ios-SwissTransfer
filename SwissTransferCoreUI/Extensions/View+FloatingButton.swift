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

import InfomaniakCoreSwiftUI
import SwiftUI

public enum FloatingActionButtonStyle {
    case newTransfer
    case firstTransfer
}

struct FloatingActionButtonModifier: ViewModifier {
    let style: FloatingActionButtonStyle
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                Group {
                    switch style {
                    case .newTransfer:
                        NewTransferButton(action: action)

                    case .firstTransfer:
                        FirstTransferButton(style: .small, action: action)
                    }
                }
                .padding([.trailing, .bottom], value: .medium)
            }
    }
}

public extension View {
    func floatingActionButton(style: FloatingActionButtonStyle, perform action: @escaping () -> Void) -> some View {
        modifier(FloatingActionButtonModifier(style: style, action: action))
    }
}
