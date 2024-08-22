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

import STCore
import STResources
import SwiftUI
import SwissTransferCore

struct TransferCell: View {
    let transfer: Transfer

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(transfer.name)
                    .font(.ST.headline)
                    .foregroundStyle(Color.ST.textPrimary)

                Text(
                    "\(transfer.castedContainer.sizeUploaded.formatted(.defaultByteCount)) · \(STResourcesStrings.Localizable.expiresIn(transfer.expiresIn))"
                )
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textSecondary)

                TransferCellThumbnailsView(files: transfer.castedContainer.files)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            STResourcesAsset.Images.chevronRight.swiftUIImage
                .iconSize(.medium)
        }
        .padding(value: .medium)
        .background(
            Color.ST.cardBackground
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .padding(.horizontal, value: .medium)
        .padding(.vertical, value: .extraSmall)
    }
}

#Preview {
    TransferCell(transfer: PreviewHelper.sampleTransfer)
}
