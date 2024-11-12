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

struct SettingsCell: View {
    let title: String
    let subtitle: String
    var leftIconAsset: STResourcesImages?
    var rightIconAsset: STResourcesImages?

    var body: some View {
        HStack(spacing: IKPadding.small) {
            if let leftIconAsset {
                Image(asset: leftIconAsset)
                    .iconSize(.large)
            }

            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(1)
                    .foregroundStyle(Color.ST.textPrimary)
                    .font(.ST.headline)
                Text(subtitle)
                    .lineLimit(1)
                    .foregroundStyle(Color.ST.textSecondary)
                    .font(.ST.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let rightIconAsset {
                Image(asset: rightIconAsset)
                    .iconSize(.large)
            }
        }
    }
}

struct SingleLabelSettingsCell: View {
    let title: String
    var rightIconAsset: STResourcesImages?

    var body: some View {
        HStack(spacing: IKPadding.small) {
            Text(title)
                .lineLimit(1)
                .foregroundStyle(Color.ST.textPrimary)
                .font(.ST.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let rightIconAsset {
                Image(asset: rightIconAsset)
                    .iconSize(.large)
            }
        }
    }
}

struct AboutSettingsCell: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(Color.ST.textPrimary)
                    .font(.ST.headline)
                Text(subtitle)
                    .foregroundStyle(Color.ST.textSecondary)
                    .font(.ST.callout)
            }
        }
    }
}

#Preview {
    SettingsCell(title: "Time",
                 subtitle: "Clock",
                 leftIconAsset: STResourcesAsset.Images.clock,
                 rightIconAsset: STResourcesAsset.Images.clock)
}
