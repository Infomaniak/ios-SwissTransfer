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
import SwissTransferCoreUI

struct SecurityCodeTextField: View {
    @FocusState private var focusedField: Int?

    @Binding var fields: [String]
    @Binding var error: UserFacingError?

    let completion: (String) -> Void

    var body: some View {
        HStack {
            ForEach(fields.indices, id: \.self) { index in
                TextField("", text: $fields[index])
                    .textFieldStyle(SecurityCodeTextFieldStyle(borderColor: error == nil ? .ST.cardBorder : .ST.error))
                    .textContentType(.oneTimeCode)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        focusedField = index
                    }
                    .focused($focusedField, equals: index)
                    .onChange(of: fields[index]) { value in
                        guard !value.isEmpty else { return }
                        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

                        withAnimation {
                            error = nil
                        }

                        if trimmedValue.count > 1 {
                            if trimmedValue.count == fields.count {
                                for (index, element) in trimmedValue.enumerated() {
                                    fields[index] = String(element)
                                }

                                // iOS focuses next field by default. We have to wait for next runloop to defocus.
                                Task { @MainActor in
                                    focusedField = nil
                                }
                            } else {
                                let firstElement = String(Array(trimmedValue)[0])
                                fields[index] = firstElement
                            }
                        }

                        if index == fields.count - 1 {
                            focusedField = nil
                            completion(fields.joined())
                            return
                        }

                        focusedField? += 1
                    }
            }
        }
        .font(.ST.body)
    }
}

#Preview {
    SecurityCodeTextField(fields: .constant(["", "", "", "", "", ""]), error: .constant(nil)) { _ in }
    SecurityCodeTextField(fields: .constant(["", "", "", "", "", ""]), error: .constant(UserFacingError.unknownError)) { _ in }
}

struct SecurityCodeTextFieldStyle: TextFieldStyle {
    let borderColor: Color

    // periphery:ignore - Protocol uses private symbol
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .overlay {
                RoundedRectangle(cornerRadius: IKRadius.small)
                    .stroke()
                    .foregroundStyle(borderColor)
                    .frame(width: 48, height: 48)
            }
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
    }
}
