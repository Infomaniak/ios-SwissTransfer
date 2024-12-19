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
import InfomaniakDI
import SwiftUI

public struct STTextEditor: View {
    @FocusState private var isFocused: Bool

    @Binding private var text: String

    private let placeholder: String
    private let size: CGFloat

    public init(text: Binding<String>, placeholder: String, size: CGFloat) {
        _text = text
        self.placeholder = placeholder
        self.size = size
    }

    public var body: some View {
        ZStack {
            if text.isEmpty {
                TextEditor(text: .constant(placeholder))
                    .foregroundStyle(Color(UIColor.placeholderText))
                    .disabled(true)
                    .introspect(.textEditor, on: .iOS(.v16, .v17, .v18)) { textView in
                        textView.textContainerInset = .zero
                    }
            }

            TextEditor(text: $text)
                .foregroundStyle(Color.ST.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .introspect(.textEditor, on: .iOS(.v16, .v17, .v18)) { textView in
                    textView.textContainerInset = .zero
                }
        }
        .frame(minHeight: size, alignment: .top)
        .padding(value: .intermediate)
        .overlay(
            RoundedRectangle(cornerRadius: IKRadius.small)
                .strokeBorder(isFocused ? Color.ST.primary : Color.ST.textFieldBorder)
        )
    }
}

#Preview {
    STTextEditor(text: .constant(""), placeholder: "", size: 88)
}