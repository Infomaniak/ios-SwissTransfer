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

import DesignSystem
import InfomaniakCoreSwiftUI
import SwiftUI

public enum BottomButtonsConstants: Sendable {
    public static let spacing = IKPadding.medium
    public static let paddingBottom = IKPadding.small
}

public struct BottomButtonsView<Buttons: View>: View {
    var spacing = BottomButtonsConstants.spacing
    let buttons: () -> Buttons

    public init(spacing: CGFloat = BottomButtonsConstants.spacing, @ViewBuilder buttons: @escaping () -> Buttons) {
        self.spacing = spacing
        self.buttons = buttons
    }

    public var body: some View {
        VStack(spacing: spacing) {
            buttons()
        }
        .ikButtonFullWidth(true)
        .controlSize(.large)
        .padding(.horizontal, value: .medium)
        .padding(.bottom, BottomButtonsConstants.paddingBottom)
    }
}

#Preview {
    BottomButtonsView {
        Button("Ok") {}
    }
}
