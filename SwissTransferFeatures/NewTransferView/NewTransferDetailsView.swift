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
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI
import InfomaniakDI

struct NewTransferDetailsView: View {
    @FocusState private var isMessageFieldFocused

    @Binding var authorEmail: String
    @Binding var recipientEmail: String
    @Binding var message: String

    let transferType: TransferType

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            if transferType == .mail {
                TextField(STResourcesStrings.Localizable.senderMailAddressPlaceholder, text: $authorEmail)
                    .textFieldStyle(NewTransferTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .onSubmit {
                        print("On Submit")
                        Task {
                            @InjectService var settingsManager: AppSettingsManager
                            try? await settingsManager.setLastAuthorEmail(authorEmail: authorEmail)
                        }
                    }

                TextField(STResourcesStrings.Localizable.recipientMailAddressPlaceholder, text: $recipientEmail)
                    .textFieldStyle(NewTransferTextFieldStyle())
                    .keyboardType(.emailAddress)
            }

            TextEditor(text: $message)
                .focused($isMessageFieldFocused)
                .frame(minHeight: 88, alignment: .top)
                .padding(value: .intermediate)
                .overlay(
                    RoundedRectangle(cornerRadius: IKRadius.small)
                        .strokeBorder(isMessageFieldFocused ? Color.ST.primary : Color.ST.textFieldBorder)
                )
        }
    }
}

#Preview {
    NewTransferDetailsView(authorEmail: .constant(""), recipientEmail: .constant(""), message: .constant(""), transferType: .link)
}
