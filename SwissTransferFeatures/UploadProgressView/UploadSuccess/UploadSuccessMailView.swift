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
import SwissTransferCore
import SwissTransferCoreUI

struct UploadSuccessMailView: View {
    @Environment(\.dismiss) private var dismiss

    let recipients: OrderedSet<String>

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            IllustrationAndTextView(
                image: STResourcesAsset.Images.beers.swiftUIImage,
                title: TransferType.mail.successTitle,
                attributedSubtitle: STResourcesStrings.Localizable.uploadSuccessEmailDescription(recipients.count),
                style: .emptyState
            )

            ListOfRecipientsView(recipients: recipients)
                .frame(maxWidth: 800)
        }
        .padding(.horizontal, value: .medium)
        .scrollableEmptyState()
        .safeAreaButtons {
            Button(action: dismiss.callAsFunction) {
                Text(STResourcesStrings.Localizable.buttonFinished)
            }
            .buttonStyle(.ikBorderedProminent)
        }
    }
}

#Preview("One Recipient") {
    UploadSuccessMailView(recipients: OrderedSet(["john.smith@ik.me"]))
}

#Preview("Many Recipients") {
    UploadSuccessMailView(recipients: OrderedSet(PreviewHelper.sampleListOfRecipients))
}
