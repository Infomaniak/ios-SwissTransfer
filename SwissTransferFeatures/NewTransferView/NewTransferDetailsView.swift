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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

struct NewTransferDetailsView: View {
    @Binding var authorEmail: String
    @Binding var recipientEmail: String
    @Binding var message: String

    let transferType: TransferType

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            if transferType == .mail {
                TextField(STResourcesStrings.Localizable.transferSenderAddressPlaceholder, text: $authorEmail) { _ in
                    saveAuthorMailAddress()
                }
                .textFieldStyle(.swissTransfer)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)

                TextField(STResourcesStrings.Localizable.transferRecipientAddressPlaceholder, text: $recipientEmail)
                    .textFieldStyle(.swissTransfer)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            STTextEditor(
                text: $message,
                placeholder: STResourcesStrings.Localizable.transferMessagePlaceholder,
                size: 88
            )
        }
    }

    private func saveAuthorMailAddress() {
        Task {
            @InjectService var settingsManager: AppSettingsManager
            try? await settingsManager.setLastAuthorEmail(authorEmail: authorEmail)
        }
    }
}

#Preview {
    NewTransferDetailsView(authorEmail: .constant(""), recipientEmail: .constant(""), message: .constant(""), transferType: .link)
}
