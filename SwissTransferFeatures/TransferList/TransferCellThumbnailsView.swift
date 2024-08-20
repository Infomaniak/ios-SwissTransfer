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

struct TransferCellThumbnailsView: View {
    let itemCount: Int

    private var additionalItemsCount: Int {
        if itemCount > 4 {
            return itemCount - 3
        }
        return 0
    }

    private var itemsToShow: Int {
        return itemCount - additionalItemsCount
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1 ... itemsToShow, id: \.self) { _ in
                SmallThumbnailView(icon: STResourcesAsset.Images.fileAdobe.swiftUIImage)
            }
            if additionalItemsCount > 0 {
                SmallMoreItemsThumbnailView(count: additionalItemsCount)
            }
        }
    }
}

#Preview {
    TransferCellThumbnailsView(itemCount: 4)
}
