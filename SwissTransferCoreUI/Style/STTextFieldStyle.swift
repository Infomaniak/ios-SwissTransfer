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

import SwiftUI

public extension TextFieldStyle where Self == STTextFieldStyle {
    @MainActor static var swissTransfer: STTextFieldStyle { STTextFieldStyle() }
}

@MainActor
public struct STTextFieldStyle: @preconcurrency TextFieldStyle {
    // periphery:ignore - Focus state is used
    @FocusState private var isFocused: Bool

    // periphery:ignore - Protocol uses private symbol
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .focused($isFocused)
            .inputStyle(isFocused: isFocused)
    }
}
