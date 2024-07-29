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

import STResources
import SwiftUI
import SwissTransferCoreUI

struct TransferDetailsMessageView: View {
    var recipient: String?
    var from: String?
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let recipient {
                Text(STResourcesStrings.Localizable.recipientHeader)
                    .sectionHeader()
                Text(recipient)
                    .roundedLabel()
            }

            Text(STResourcesStrings.Localizable.messageHeader)
                .sectionHeader()

            VStack(alignment: .leading, spacing: 0) {
                if let from {
                    HStack(spacing: 8) {
                        Text(STResourcesStrings.Localizable.fromHeader)
                            .font(.ST.callout)
                            .foregroundStyle(STResourcesAsset.Colors.greyOrca.swiftUIColor)
                        Text(from)
                            .roundedLabel()
                    }
                    .padding(24)

                    DividerView()
                }

                Text(message)
                    .font(.ST.callout)
                    .foregroundStyle(STResourcesAsset.Colors.greyOrca.swiftUIColor)
                    .padding(24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(STResourcesAsset.Colors.greyPolarBear.swiftUIColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TransferDetailsMessageView(
        recipient: "john.smith@ik.me",
        from: "john.smith@ik.me",
        message: "Salut voici les images de la soirée chez Tanguy ! Hesite pas à me partager les tiennes dès que t'as un moment :)"
    )
}
