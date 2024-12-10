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
import STResources
import SwiftUI
import SwissTransferCoreUI

enum PasswordInputFocus: Hashable, Sendable {
    case secure
    case clear
}

struct PasswordSettingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isOn = false
    @FocusState private var focusedField: PasswordInputFocus?

    @Binding var password: String

    private var isShowingPassword: Bool {
        return focusedField == .clear
    }

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.large) {
            Text(STResourcesStrings.Localizable.settingsPasswordTitle)
                .font(.ST.title2)
                .foregroundStyle(Color.ST.textPrimary)

            Text(STResourcesStrings.Localizable.settingsPasswordDescription)
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)

            Toggle(isOn: $isOn) {
                Text(STResourcesStrings.Localizable.settingsPasswordToggleDescription)
                    .font(.ST.calloutMedium)
                    .foregroundStyle(Color.ST.textPrimary)
            }
            .onChange(of: isOn, perform: didUpdateToggle)

            if isOn {
                HStack {
                    ZStack {
                        TextField(STResourcesStrings.Localizable.settingsOptionPassword, text: $password)
                            .focused($focusedField, equals: .clear)
                            .opacity(isShowingPassword ? 1 : 0)

                        SecureField(STResourcesStrings.Localizable.settingsOptionPassword, text: $password)
                            .focused($focusedField, equals: .secure)
                            .opacity(isShowingPassword ? 0 : 1)
                    }
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
                .overlay(
                    RoundedRectangle(cornerRadius: IKRadius.small)
                        .strokeBorder(Color.ST.textFieldBorder)
                )
            }
        }
        .padding(value: .medium)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.ST.background)
        .safeAreaButtons {
            Button(action: dismiss.callAsFunction) {
                Text(STResourcesStrings.Localizable.buttonConfirm)
            }
            .buttonStyle(.ikBorderedProminent)
        }
    }

    private func didUpdateToggle(_ isOn: Bool) {
        if isOn {
            focusedField = .secure
        } else {
            password = ""
        }
    }

    private func toggleShowPassword() {
        focusedField = isShowingPassword ? .secure : .clear
    }
}

#Preview {
    PasswordSettingView(password: .constant(""))
}
