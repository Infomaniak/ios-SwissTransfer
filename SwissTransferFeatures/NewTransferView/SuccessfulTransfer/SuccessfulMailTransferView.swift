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

struct SuccessfulMailTransferView: View {
    let recipients: [String]
    let dismiss: () -> Void

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: IKPadding.medium) {
                    LargeEmptyStateView(
                        image: STResourcesAsset.Images.beersHands.swiftUIImage,
                        title: STResourcesStrings.Localizable.uploadSuccessEmailTitle,
                        subtitle: STResourcesStrings.Localizable.uploadSuccessEmailDescription,
                        imageHorizontalPadding: 0
                    )

                    if let email = recipients.first {
                        Text(email)
                            .roundedLabel()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button(action: dismiss) {
                Text(STResourcesStrings.Localizable.buttonFinished)
            }
            .buttonStyle(.ikBorderedProminent)
            .ikButtonFullWidth(true)
            .controlSize(.large)
            .padding(value: .medium)
        }
    }
}

#Preview("One Recipient") {
    SuccessfulMailTransferView(recipients: ["john.smith@ik.me"]) {}
}

#Preview("Many Recipient") {
    let recipients = Array(repeating: "short@ik.me", count: 5)
        + Array(repeating: "long-email@infomaniak.com", count: 5)
        + Array(repeating: "middle@infomaniak.com", count: 5)
    SuccessfulMailTransferView(recipients: recipients.shuffled()) {}
}
