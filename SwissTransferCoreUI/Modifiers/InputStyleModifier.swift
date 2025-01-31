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

public extension View {
    func inputStyle(isFocused: Bool, withPadding: Bool = true, error: InputErrorState? = nil) -> some View {
        modifier(InputStyleModifier(isFocused: isFocused, withPadding: withPadding, error: error))
    }
}

public enum InputErrorState {
    case error
    case errorWithMessage(String)
}

struct InputStyleModifier: ViewModifier {
    let isFocused: Bool
    let withPadding: Bool
    let error: InputErrorState?

    private var strokeColor: Color {
        guard error == nil else { return Color.ST.error }
        return isFocused ? Color.ST.primary : Color.ST.textFieldBorder
    }

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: IKPadding.micro) {
            content
                .padding(withPadding ? IKPadding.small : 0)
                .overlay(
                    RoundedRectangle(cornerRadius: IKRadius.small)
                        .strokeBorder(strokeColor, lineWidth: isFocused ? 2 : 1)
                )

            if case .errorWithMessage(let message) = error {
                Text(message)
                    .font(.ST.caption)
                    .foregroundStyle(Color.ST.error)
            }
        }
    }
}

#Preview {
    VStack {
        TextField("Preview", text: .constant(""))
            .inputStyle(isFocused: false)

        TextField("Preview", text: .constant(""))
            .inputStyle(isFocused: true)
    }
}
