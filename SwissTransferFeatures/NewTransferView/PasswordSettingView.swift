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
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STResources
import SwiftUI
import SwissTransferCoreUI

struct PasswordSettingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isOn: Bool
    @State private var error: InputErrorState?

    @FocusState private var isFocused: Bool

    @Binding var password: String

    private var isButtonDisabled: Bool {
        return isOn && !isPasswordValid
    }

    private var isPasswordValid: Bool {
        return password.count >= RootTransferViewModel.minPasswordLength
            && password.count <= RootTransferViewModel.maxPasswordLength
    }

    init(password: Binding<String>) {
        _isOn = State(wrappedValue: !password.wrappedValue.isEmpty)
        _password = password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
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
                    .onChange(of: isOn) { newValue in
                        @InjectService var matomo: MatomoUtils
                        matomo.track(eventWithCategory: .settingsLocalPassword, name: .togglePassword, value: newValue ? 1 : 0)
                    }

                    if isOn {
                        TogglableSecureTextField(password: $password, error: error)
                            .focused($isFocused)
                    }
                }
                .padding(value: .medium)
            }
            .background(Color.ST.background)
            .onChange(of: password) { _ in
                guard isPasswordValid else {
                    error = .errorWithMessage(STResourcesStrings.Localizable.errorTransferPasswordLength)
                    return
                }

                error = nil
            }
            .safeAreaButtons {
                Button(action: dismiss.callAsFunction) {
                    Text(STResourcesStrings.Localizable.buttonConfirm)
                }
                .buttonStyle(.ikBorderedProminent)
                .disabled(isButtonDisabled)
            }
            .stNavigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private func didUpdateToggle(_ isOn: Bool) {
        if isOn {
            isFocused = true
        } else {
            password = ""
        }
    }
}

#Preview {
    PasswordSettingView(password: .constant(""))
}
