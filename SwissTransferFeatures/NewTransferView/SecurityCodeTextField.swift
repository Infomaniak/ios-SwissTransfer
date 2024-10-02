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
import SwissTransferCoreUI

public enum SecurityCodeFieldStyle {
    case normal
    case error

    var borderColor: Color {
        switch self {
        case .normal:
            return Color.ST.cardBorder
        case .error:
            return .red
        }
    }
}

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

    @Binding var style: SecurityCodeFieldStyle

    let completion: (String) -> Void

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

                SecurityCodeField(value: field, isFocused: focus, style: style) {
                    guard index < fields.count - 1 else {
                        focus.wrappedValue = false
                        completion(fields.joined())
                        return
                    }
                    focusedField? += 1
                }
                .focused($focusedField, equals: index)
            }
        }
        .font(.ST.body)
    }
}

#Preview {
    SecurityCodeTextField(style: .constant(.normal)) { _ in }
}

private struct SecurityCodeField: View {
    @Binding var value: String
    @Binding var isFocused: Bool
    let style: SecurityCodeFieldStyle
    let onComplete: () -> Void

    var body: some View {
        TextField("", text: $value)
            .frame(width: 10)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .stroke()
                    .foregroundStyle(style.borderColor)
                    .frame(width: 48, height: 48)
            }
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
            .onChange(of: isFocused) { focus in
                guard focus else { return }
                value = ""
            }
            .onChange(of: value) { value in
                guard !value.isEmpty else { return }
                if value.count > 1 {
                    let firstElement = String(Array(value)[0])
                    self.value = firstElement
                }
                onComplete()
            }
    }
}

#Preview {
    SecurityCodeField(value: .constant(""), isFocused: .constant(true), style: .normal) {}
}
