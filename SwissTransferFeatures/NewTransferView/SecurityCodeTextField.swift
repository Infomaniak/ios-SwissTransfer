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

    var color: Color {
        switch self {
        case .normal:
            return Color.ST.cardBorder
        case .error:
            return Color.ST.error
        }
    }

    var label: String? {
        if self == .error {
            return "Le code saisie est incorrect"
        }
        return nil
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
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 11) {
                ForEach(fields.indices, id: \.self) { index in
                    TextField("", text: $fields[index])
                        .textFieldStyle(SecurityCodeTextFieldStyle(style: style))
                        .onTapGesture {
                            focusedField = index
                        }
                        .focused($focusedField, equals: index)
                        .onChange(of: fields[index]) { value in
                            guard !value.isEmpty else { return }
                            style = .normal
                            if value.count > 1 {
                                let firstElement = String(Array(value)[0])
                                fields[index] = firstElement
                            }

                            guard index < fields.count - 1 else {
                                focusedField = nil
                                completion(fields.joined())
                                return
                            }
                            focusedField? += 1
                        }
                }
            }
            .onChange(of: focusedField) { index in
                guard let index else { return }
                fields[index] = ""
            }
            .font(.ST.body)

            if let label = style.label {
                Text(label)
                    .foregroundStyle(style.color)
                    .font(.ST.caption)
            }
        }
    }
}

#Preview {
    SecurityCodeTextField(style: .constant(.normal)) { _ in }
}

struct SecurityCodeTextFieldStyle: TextFieldStyle {
    let style: SecurityCodeFieldStyle

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(width: 10)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .stroke()
                    .foregroundStyle(style.color)
                    .frame(width: 48, height: 48)
            }
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
    }
}
