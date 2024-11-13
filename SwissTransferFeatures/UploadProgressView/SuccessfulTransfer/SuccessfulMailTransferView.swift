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
import SwissTransferCore
import SwissTransferCoreUI

struct SuccessfulMailTransferView: View {
    @Environment(\.dismissModal) private var dismissModal

    let recipients: [String]

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            LargeEmptyStateView(
                image: STResourcesAsset.Images.beers.swiftUIImage,
                title: TransferType.mail.successTitle,
                subtitle: STResourcesStrings.Localizable.uploadSuccessEmailDescription
            )

            FlowLayout(verticalSpacing: IKPadding.small, horizontalSpacing: IKPadding.small) {
                ForEach(recipients, id: \.self) { recipient in
                    Text(recipient)
                        .roundedLabel()
                }
            }
            .padding(.horizontal, value: .medium)
            .frame(maxWidth: 800)
        }
        .scrollableEmptyState()
        .safeAreaButtons {
            Button(action: dismissModal) {
                Text(STResourcesStrings.Localizable.buttonFinished)
            }
            .buttonStyle(.ikBorderedProminent)
        }
    }
}

#Preview("One Recipient") {
    SuccessfulMailTransferView(recipients: ["john.smith@ik.me"])
}

#Preview("Many Recipients") {
    let recipients = Array(repeating: "short@ik.me", count: 2)
        + Array(repeating: "long-email@infomaniak.com", count: 2)
        + Array(repeating: "middle@infomaniak.com", count: 3)
    SuccessfulMailTransferView(recipients: recipients.shuffled())
}
