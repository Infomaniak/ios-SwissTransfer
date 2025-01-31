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

import DesignSystem
import InfomaniakCoreSwiftUI
import SwiftUI

extension View {
    func importingItem(controlSize: ControlSize) -> some View {
        modifier(ImportingItemModifier(controlSize: controlSize))
    }
}

struct ImportingItemModifier: ViewModifier {
    let controlSize: ControlSize

    func body(content: Content) -> some View {
        content
            .opacity(0.4)
            .background(Color.ST.background, in: .rect(cornerRadius: IKRadius.large))
            .overlay(alignment: .bottomTrailing) {
                ProgressView()
                    .controlSize(controlSize)
                    .tint(nil)
                    .padding(value: .mini)
            }
    }
}

#Preview {
    Rectangle()
        .frame(width: 400, height: 400)
        .importingItem(controlSize: .regular)
}
