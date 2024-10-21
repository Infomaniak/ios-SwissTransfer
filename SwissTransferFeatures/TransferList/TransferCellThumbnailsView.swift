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

struct TransferCellThumbnailsView: View {
    let files: [FileUi]

    private var additionalItemsCount: Int {
        if files.count > 99 + 3 { // +3 visible
            return 99
        }
        if files.count > 4 {
            return files.count - 3
        }
        return 0
    }

    private var itemsToShow: [FileUi] {
        return Array(files.prefix(3))
    }

    var body: some View {
        HStack(spacing: IKPadding.small) {
            ForEach(itemsToShow, id: \.uid) { file in
                SmallThumbnailView(url: file.localURL, mimeType: file.mimeType ?? "")
            }
            if additionalItemsCount > 0 {
                SmallMoreItemsThumbnailView(count: additionalItemsCount)
            }
        }
    }
}

#Preview {
    TransferCellThumbnailsView(files: [PreviewHelper.sampleFile, PreviewHelper.sampleFile, PreviewHelper.sampleFile])
}
