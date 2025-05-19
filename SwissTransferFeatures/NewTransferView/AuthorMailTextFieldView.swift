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

import InfomaniakCore
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

struct AuthorMailTextFieldView: View {
    @FocusState private var isFocused

    @Binding var authorEmail: String

    private var error: InputErrorState? {
        let trimmedText = authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty && !EmailChecker(email: trimmedText).validate() {
            return .errorWithMessage(STResourcesStrings.Localizable.invalidAddress)
        } else {
            return nil
        }
    }

    var body: some View {
        TextField(STResourcesStrings.Localizable.transferSenderAddressPlaceholder, text: $authorEmail) { _ in
            saveAuthorMailAddress()
        }
        .inputStyle(isFocused: isFocused, error: error)
        .focused($isFocused)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .textInputAutocapitalization(.never)
        .onTapGesture {
            isFocused = true
        }
    }

    private func saveAuthorMailAddress() {
        let trimmedAuthorEmail = authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAuthorEmail.isEmpty, EmailChecker(email: trimmedAuthorEmail).validate() else {
            return
        }

        authorEmail = trimmedAuthorEmail

        Task {
            @InjectService var settingsManager: AppSettingsManager
            try? await settingsManager.setLastAuthorEmail(authorEmail: trimmedAuthorEmail)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var authorEmail = ""
    AuthorMailTextFieldView(authorEmail: $authorEmail)
}
