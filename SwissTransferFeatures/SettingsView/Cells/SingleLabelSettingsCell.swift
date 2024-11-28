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
import SwissTransferCore

struct SingleLabelSettingsCell: View {
    let title: String
    var rightIconAsset: STResourcesImages?

    var body: some View {
        HStack(spacing: IKPadding.small) {
            Text(title)
                .lineLimit(1)
                .foregroundStyle(Color.ST.textPrimary)
                .font(.ST.body)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let rightIconAsset {
                Image(asset: rightIconAsset)
                    .iconSize(.medium)
                    .foregroundStyle(Color.ST.textSecondary)
            }
        }
    }
}

#Preview {
    SingleLabelSettingsCell(title: "Title")
}