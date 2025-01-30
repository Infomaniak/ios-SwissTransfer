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
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct HeaderView: View {
    let filesCount: Int
    let transferSize: Int64
    let expiringTimestamp: Int64
    let downloadLeft: Int32
    let downloadLimit: Int32
    let transferDirection: TransferDirection?

    private var downloadedTimes: Int {
        Int(downloadLimit) - Int(downloadLeft)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Label(
                title: {
                    Text(
                        "\(STResourcesStrings.Localizable.filesCount(filesCount)) · \(transferSize.formatted(.defaultByteCount))"
                    )
                },
                icon: { STResourcesAsset.Images.fileZip.swiftUIImage }
            )
            .labelStyle(.horizontal)

            DividerView()

            Label(
                title: { Text(expiringTimestamp.formatted(.expiring)) },
                icon: { STResourcesAsset.Images.clock.swiftUIImage }
            )
            .labelStyle(.horizontal)

            if transferDirection == .sent {
                DividerView()

                Label(
                    title: { Text(STResourcesStrings.Localizable.downloadedTransferLabel(downloadedTimes, Int(downloadLimit))) },
                    icon: { STResourcesAsset.Images.fileDownload.swiftUIImage }
                )
                .labelStyle(.horizontal)
            }
        }
    }
}

#Preview {
    HeaderView(
        filesCount: 4,
        transferSize: 8561,
        expiringTimestamp: 0,
        downloadLeft: 249,
        downloadLimit: 250,
        transferDirection: .received
    )
}
