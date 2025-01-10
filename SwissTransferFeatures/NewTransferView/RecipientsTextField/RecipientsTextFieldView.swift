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

import InfomaniakCore
import InfomaniakCoreSwiftUI
import OrderedCollections
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

enum RecipientFocus: Hashable {
    case textField
    case recipient(String)
}

struct RecipientsTextFieldView: View {
    @State private var text = ""
    @FocusState private var isFocused: RecipientFocus?

    @Binding var recipients: OrderedSet<String>

    private var placeholder: String {
        guard recipients.isEmpty else { return "" }
        return STResourcesStrings.Localizable.transferRecipientAddressPlaceholder
    }

    var body: some View {
        FlowLayout(alignment: .leading, verticalSpacing: IKPadding.small, horizontalSpacing: IKPadding.small) {
            if isFocused == nil {
                CollapsedRecipientsFlowView(isFocused: _isFocused, recipients: recipients)
            } else {
                ExpandedRecipientsFlowView(isFocused: _isFocused, recipients: $recipients)
            }

            TextField(placeholder, text: $text)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .focused($isFocused, equals: .textField)
                .onSubmit(didSubmitNewRecipient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .inputStyle(isFocused: isFocused != nil)
    }

    private func didSubmitNewRecipient() {
        defer {
            isFocused = .textField
        }

        let trimmedRecipient = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRecipient.isEmpty, EmailChecker(email: trimmedRecipient).validate() else { return }

        recipients.append(text)
        text = ""
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var fullRecipients = OrderedSet<String>(PreviewHelper.sampleListOfRecipients)
    @Previewable @State var emptyRecipients = OrderedSet<String>()

    VStack {
        RecipientsTextFieldView(recipients: $fullRecipients)
        RecipientsTextFieldView(recipients: $emptyRecipients)
    }
    .padding()
}
