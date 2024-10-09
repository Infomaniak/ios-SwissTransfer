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

import InfomaniakCoreUI
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
        VStack(alignment: .leading, spacing: 24) {
            Text("Protèges ton transfert avec un mot de passe")
                .font(.ST.title2)
                .foregroundStyle(Color.ST.textPrimary)

            Text("Tes destinataires devront saisir le mot de passe pour télécharger les fichiers.")
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)

            Toggle(isOn: $isOn) {
                Text("Activer la protection")
                    .font(.ST.calloutMedium)
                    .foregroundStyle(Color.ST.textPrimary)
            }

            if isOn {
                HStack {
                    ZStack {
                        TextField("Mot de passe", text: $password)
                            .opacity(isShowingPassword ? 1 : 0)
                            .focused($isVisibleFieldFocused)

                        SecureField("Mot de passe", text: $password)
                            .opacity(isShowingPassword ? 0 : 1)
                            .focused($isSecureFieldFocused)
                    }

                    Button {
                        toggleShowPassword()
                    } label: {
                        STResourcesAsset.Images.eye.swiftUIImage
                    }
                    .foregroundStyle(Color.ST.textSecondary)
                }
                .padding(value: .intermediate)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.ST.textFieldBorder)
                )
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .floatingContainer {
            Button {
                // Confirm
            } label: {
                Text("Confirmer")
            }
            .buttonStyle(.ikBorderedProminent)
            .ikButtonFullWidth(true)
            .controlSize(.large)
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
