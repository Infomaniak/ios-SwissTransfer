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
import InfomaniakCoreSwiftUI
import OrderedCollections
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

struct NewTransferDetailsView: View {
    @Binding var authorEmail: String
    @Binding var recipientsEmail: OrderedSet<String>
    @Binding var message: String

    let transferType: TransferType

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            if transferType == .mail {
                AuthorMailTextFieldView(authorEmail: $authorEmail)
                RecipientsTextFieldView(recipients: $recipientsEmail)
            }

            STTextEditor(
                text: $message,
                placeholder: STResourcesStrings.Localizable.transferMessagePlaceholder,
                size: 88
            )
        }
    }
}

#Preview {
    NewTransferDetailsView(
        authorEmail: .constant(""),
        recipientsEmail: .constant(OrderedSet()),
        message: .constant(""),
        transferType: .link
    )
}
