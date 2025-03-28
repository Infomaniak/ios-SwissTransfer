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

import OrderedCollections
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct CollapsedRecipientsFlowView: View {
    let recipients: OrderedSet<String>

    private var hiddenRecipientsCount: Int {
        return recipients.dropFirst().count
    }

    var body: some View {
        Group {
            if let firstRecipient = recipients.first {
                STFocusableChipView(recipient: firstRecipient, shouldDisplayButton: false)
            }
            if hiddenRecipientsCount > 0 {
                STFocusableChipView(recipient: "+\(hiddenRecipientsCount)", shouldDisplayButton: false)
            }
        }
        .disabled(true)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @FocusState var isFocused: RecipientFocus?

    CollapsedRecipientsFlowView(recipients: OrderedSet<String>(PreviewHelper.sampleListOfRecipients))
}
