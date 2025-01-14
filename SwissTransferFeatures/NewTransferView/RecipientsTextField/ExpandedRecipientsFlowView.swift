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
import OrderedCollections
import SwiftUI
import SwissTransferCoreUI

struct ExpandedRecipientsFlowView: View {
    @FocusState var focusedView: RecipientFocus?

    @Binding var recipients: OrderedSet<String>

    private var hasFocus: Bool {
        return focusedView != nil
    }

    var body: some View {
        ForEach(recipients, id: \.hash) { recipient in
            STFocusableChipView(recipient: recipient, shouldDisplayButton: hasFocus) {
                didPressTabKey(recipient)
            } removeRecipient: {
                removeRecipient(recipient)
            }
            .focused($focusedView, equals: .recipient(recipient))
        }
    }

    private func didPressTabKey(_ recipient: String) {
        if let indexOfChip = recipients.firstIndex(of: recipient), indexOfChip < recipients.count - 1 {
            focusedView = .recipient(recipients[indexOfChip + 1])
        } else {
            focusedView = .textField
        }
    }

    private func removeRecipient(_ recipient: String) {
        recipients.remove(recipient)
        focusedView = .textField
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @FocusState var focusedView: RecipientFocus?
    @Previewable @State var recipients = OrderedSet<String>()

    ExpandedRecipientsFlowView(focusedView: _focusedView, recipients: $recipients)
}
