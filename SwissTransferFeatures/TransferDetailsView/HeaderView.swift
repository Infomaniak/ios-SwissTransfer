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
import SwissTransferCoreUI

struct HeaderView: View {
    let transfer: Transfer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(transfer.detailDate)
                .sectionHeader()
                .padding(.bottom, value: .small)

            Label(
                title: { Text("4 fichiers") },
                icon: { STResourcesAsset.Images.fileZip.swiftUIImage }
            )
            .labelStyle(.horizontal)

            DividerView()

            Label(
                title: { Text(STResourcesStrings.Localizable.expiresIn(transfer.expiresIn)) },
                icon: { STResourcesAsset.Images.clock.swiftUIImage }
            )
            .labelStyle(.horizontal)

            DividerView()

            Label(
                title: { Text(STResourcesStrings.Localizable.downloadedTransferLabel(0, 250)) },
                icon: { STResourcesAsset.Images.fileDownload.swiftUIImage }
            )
            .labelStyle(.horizontal)
        }
    }
}

#Preview {
    HeaderView(transfer: PreviewHelper.sampleTransfer)
}
