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

extension TransferType {

}

struct SuccesfulLinkTransferView: View {
    let type: TransferType

    var body: some View {
        VStack(spacing: 32) {
            STResourcesAsset.Images.beers.swiftUIImage

            Text(STResourcesStrings.Localizable.uploadSuccessQrTitle)
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)

            // TODO: QR Code
            Rectangle()
                .fill(Color.black)
                .frame(width: 160, height: 160)

            Text(STResourcesStrings.Localizable.uploadSuccessLinkDescription)
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview("QR Code") {
    SuccesfulLinkTransferView(type: .qrcode)
}

#Preview("Link") {
    SuccesfulLinkTransferView(type: .link)
}
