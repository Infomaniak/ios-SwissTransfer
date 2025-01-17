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
    @Environment(\.dismiss) private var dismiss

    @State private var isOn: Bool
    @FocusState private var isFocused: Bool

    @Binding var password: String

    private var isButtonDisabled: Bool {
        return isOn && password.isEmpty
    }

    init(password: Binding<String>) {
        _isOn = State(wrappedValue: !password.wrappedValue.isEmpty)
        _password = password
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
                TogglableSecureTextField(password: $password)
                    .focused($isFocused)
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
            .disabled(isButtonDisabled)
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
