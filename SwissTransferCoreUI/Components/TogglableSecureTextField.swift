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

import InfomaniakCoreSwiftUI
import STResources
import SwiftUI

public enum PasswordInputFocus: Hashable, Sendable {
    case secure
    case clear
}

public struct TogglableSecureTextField: View {
    @FocusState private var focusedField: PasswordInputFocus?

    @Binding var password: String

    let error: InputErrorState?

    private var isShowingPassword: Bool {
        return focusedField == .clear
    }

    public init(password: Binding<String>, error: InputErrorState? = nil) {
        _password = password
        self.error = error
    }

    public var body: some View {
        HStack {
            ZStack {
                SecureField(STResourcesStrings.Localizable.settingsOptionPassword, text: $password)
                    .focused($focusedField, equals: .secure)
                    .opacity(isShowingPassword ? 0 : 1)

                TextField(STResourcesStrings.Localizable.settingsOptionPassword, text: $password)
                    .focused($focusedField, equals: .clear)
                    .opacity(isShowingPassword ? 1 : 0)
            }
            .keyboardType(.asciiCapable)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(value: .intermediate)

            Button(action: toggleShowPassword) {
                if isShowingPassword {
                    STResourcesAsset.Images.eye.swiftUIImage
                        .iconSize(.medium)
                } else {
                    STResourcesAsset.Images.eyeSlash.swiftUIImage
                        .iconSize(.medium)
                }
            }
            .foregroundStyle(Color.ST.textSecondary)
            .padding(value: .intermediate)
        }
        .inputStyle(isFocused: focusedField != nil, withPadding: false, error: error)
    }

    private func toggleShowPassword() {
        focusedField = isShowingPassword ? .secure : .clear
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var password = ""
    TogglableSecureTextField(password: $password)
}
