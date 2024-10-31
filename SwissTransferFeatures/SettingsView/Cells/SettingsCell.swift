//
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
import InfomaniakCoreSwiftUI

// TODO: Navigation link
struct SettingsCell: View {
    let title: String
    let subtitle: String
    let leftIconAsset: STResourcesImages
    let rightIconAsset: STResourcesImages
    let action: () -> Void // remove

    var body: some View {
        Button(action: action) {
            HStack(spacing: IKPadding.small) {
                Image(asset: leftIconAsset)
                    .iconSize(.large)

                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundStyle(Color.ST.textPrimary)
                        .font(.ST.headline)
                    Text(subtitle)
                        .foregroundStyle(Color.ST.textSecondary)
                        .font(.ST.callout)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(asset: rightIconAsset)
                    .iconSize(.large)
            }
        }
    }
}

struct SingleLabelSettingsCell: View {
    let title: String
    let rightIconAsset: STResourcesImages
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.ST.textPrimary)
                    .font(.ST.headline)

                Spacer()
                Image(asset: rightIconAsset)
                    .iconSize(.large)
                    .padding(.trailing, value: .small)
            }
        }
    }
}

struct AboutSettingsCell: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
}

// #Preview {
//    SettingsCell()
// }
