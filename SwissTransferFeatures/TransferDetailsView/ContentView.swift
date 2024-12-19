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

struct ContentView: View {
    private let columns = [
        GridItem(.flexible(), spacing: IKPadding.medium),
        GridItem(.flexible(), spacing: IKPadding.medium)
    ]

    let transfer: TransferUi

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Text(STResourcesStrings.Localizable.transferContentHeader)
                .sectionHeader()

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: IKPadding.medium,
                pinnedViews: []
            ) {
                ForEach(transfer.files, id: \.uid) { file in
                    LargeFileCell(
                        fileName: file.fileName,
                        fileSize: file.fileSize,
                        url: file.localURL,
                        mimeType: file.mimeType ?? ""
                    )
                    .overlay {
                        DownloadButton(transfer: transfer, file: file)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(value: .small)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(transfer: PreviewHelper.sampleTransfer)
}
