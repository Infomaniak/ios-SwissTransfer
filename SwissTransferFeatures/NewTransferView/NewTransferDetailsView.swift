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

struct NewTransferDetailsView: View {
    @EnvironmentObject private var newTransferManager: NewTransferManager

    @State private var sender = ""
    @State private var recipient = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            if newTransferManager.transferType == .mail {
                TextField(STResourcesStrings.Localizable.senderMailAddressPlaceholder, text: $sender)
                    .textFieldStyle(NewTransferTextFieldStyle())
                    .keyboardType(.emailAddress)
                TextField(STResourcesStrings.Localizable.recipientMailAddressPlaceholder, text: $recipient)
                    .textFieldStyle(NewTransferTextFieldStyle())
                    .keyboardType(.emailAddress)
            }
            TextField(STResourcesStrings.Localizable.messagePlaceholder, text: $message, axis: .vertical)
                .textFieldStyle(NewTransferTextFieldStyle(height: 88))
        }
    }
}

#Preview {
    NewTransferDetailsView()
}
