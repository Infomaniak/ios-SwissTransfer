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

struct SecurityCodeTextField: View {
    @State private var fields: [String] = [
        "",
        "",
        "",
        "",
        "",
        ""
    ]
    @FocusState private var focusedField: Int?

    var body: some View {
        HStack(spacing: 11) {
            ForEach(fields.indices, id: \.self) { index in
                let field = Binding {
                    fields[index]
                } set: { value in
                    fields[index] = value
                }

                let focus = Binding {
                    focusedField == index
                } set: { value in
                    guard value else {
                        focusedField = nil
                        return
                    }
                    focusedField = index
                }

                SecurityCodeField(value: field, isFocused: focus) {
                    guard index < fields.count - 1 else {
                        focus.wrappedValue = false
                        return
                    }
                    focusedField? += 1
                }
                .focused($focusedField, equals: index)
            }
        }
        .padding(32)
        .font(.ST.body)
    }
}

#Preview {
    SecurityCodeTextField()
}

private struct SecurityCodeField: View {
    @Binding var value: String
    @Binding var isFocused: Bool
    let onComplete: () -> Void

    var body: some View {
        TextField("", text: $value)
            .frame(width: 10)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .stroke()
                    .foregroundStyle(Color.ST.cardBorder)
                    .frame(width: 48, height: 48)
                    .onTapGesture {
                        isFocused = true
                    }
            }
            .frame(width: 48, height: 48)
            .onChange(of: isFocused) { focus in
                guard focus else { return }
                value = ""
            }
            .onChange(of: value) { value in
                if value.count == 1 {
                    onComplete()
                }
            }
    }
}

#Preview {
    SecurityCodeField(value: .constant(""), isFocused: .constant(true)) {}
}
