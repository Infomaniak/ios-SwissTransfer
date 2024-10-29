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

public extension View {
    func safeAreaButtons<Buttons: View>(
        spacing: CGFloat = IKPadding.medium,
        background: Color = Color.ST.background,
        @ViewBuilder content: () -> Buttons
    ) -> some View {
        modifier(SafeAreaButtonsModifier(spacing: spacing, background: background, buttons: content()))
    }
}

struct SafeAreaButtonsModifier<Buttons: View>: ViewModifier {
    let spacing: CGFloat
    let background: Color
    let buttons: Buttons

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: IKPadding.medium) {
                    buttons
                }
                .ikButtonFullWidth(true)
                .controlSize(.large)
                .padding(value: .medium)
                .background(Color.ST.background)
            }
    }
}
