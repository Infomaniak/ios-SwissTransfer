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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct TransferCell: View {
    @LazyInjectService private var injection: SwissTransferInjection

    @EnvironmentObject private var mainViewState: MainViewState

    let transfer: TransferUi

    private var isSelected: Bool {
        mainViewState.selectedTransfer?.uuid == transfer.uuid
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: IKPadding.small) {
                Text(transfer.name)
                    .font(.ST.headline)
                    .foregroundStyle(Color.ST.textPrimary)

                HStack(spacing: 0) {
                    Text(transfer.sizeUploaded, format: .defaultByteCount)
                    Text(" · ")
                    Text(transfer.expirationDateTimestamp.formatted(.expiring))
                }
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textSecondary)

                TransferCellThumbnailsView(transfer: transfer)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            STResourcesAsset.Images.chevronRight.swiftUIImage
                .iconSize(.medium)
                .foregroundStyle(Color.ST.textPrimary)
        }
        .padding(value: .medium)
        .background(Color.ST.cardBackground, in: .rect(cornerRadius: IKRadius.large))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: IKRadius.large))
        .contextMenu {
            Button(STResourcesStrings.Localizable.buttonDeleteTransfer, role: .destructive) {
                Task {
                    try? await injection.transferManager.deleteTransfer(transferUUID: transfer.uuid)
                }
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: IKRadius.large)
                    .stroke(Color.ST.onRecipientLabelBackground, lineWidth: 1)
            }
        }
        .padding(.horizontal, value: .medium)
        .padding(.vertical, value: .extraSmall)
        .appBackground()
    }
}

#Preview {
    TransferCell(transfer: PreviewHelper.sampleTransfer)
}
