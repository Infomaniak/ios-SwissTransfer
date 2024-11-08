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

struct PasswordSettingView: View {
    @State private var isOn = false
    @State private var password = ""
    @State private var isShowingPassword = false

    @FocusState private var isSecureFieldFocused: Bool
    @FocusState private var isVisibleFieldFocused: Bool

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

            if isOn {
                HStack {
                    ZStack {
                        TextField(STResourcesStrings.Localizable.settingsOptionPassword, text: $password)
                            .opacity(isShowingPassword ? 1 : 0)
                            .focused($isVisibleFieldFocused)

                        SecureField(STResourcesStrings.Localizable.settingsOptionPassword, text: $password)
                            .opacity(isShowingPassword ? 0 : 1)
                            .focused($isSecureFieldFocused)
                    }

                    Button {
                        toggleShowPassword()
                    } label: {
                        if isShowingPassword {
                            STResourcesAsset.Images.eye.swiftUIImage
                        } else {
                            STResourcesAsset.Images.eyeSlash.swiftUIImage
                        }
                    }
                    .foregroundStyle(Color.ST.textSecondary)
                }
                .padding(value: .intermediate)
                .overlay(
                    RoundedRectangle(cornerRadius: IKRadius.small)
                        .strokeBorder(Color.ST.textFieldBorder)
                )
            }
        }
        .padding(value: .medium)
        .frame(maxHeight: .infinity, alignment: .top)
        .safeAreaButtons {
            Button {
                // Confirm
            } label: {
                Text(STResourcesStrings.Localizable.buttonConfirm)
            }
            .buttonStyle(.ikBorderedProminent)
        }
    }

    private func toggleShowPassword() {
        isShowingPassword.toggle()

        if isShowingPassword && isSecureFieldFocused {
            isSecureFieldFocused = false
            isVisibleFieldFocused = true
        } else if !isShowingPassword && isVisibleFieldFocused {
            isVisibleFieldFocused = false
            isSecureFieldFocused = true
        }
    }
}

#Preview {
    PasswordSettingView()
}
