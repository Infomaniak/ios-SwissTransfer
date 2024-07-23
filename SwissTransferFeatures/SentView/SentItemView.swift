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

struct SentItemView: View {
    let itemCount: Int

    private var additionalCount: Int? {
        if itemCount > 4 {
            return itemCount - 3
        }
        return nil
    }

    private var itemToShow: Int {
        return itemCount - (additionalCount ?? 0)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Rapport d'oral - Master 2")
                    .font(.bodyMedium)
                    .foregroundStyle(STResourcesAsset.Colors.greyOrca.swiftUIColor)
                HStack {
                    Text("50 Mo")
                    Text("·")
                    Text("Expire dans 30 jours")
                }
                .font(.bodySmallRegular)
                .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)

                HStack(spacing: 8) {
                    ForEach(1 ... itemToShow, id: \.self) { _ in
                        STResourcesAsset.Images.fileAdobe.swiftUIImage
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(8)
                            .background(
                                STResourcesAsset.Colors.greyPolarBear.swiftUIColor
                                    .clipShape(Circle())
                            )
                            .frame(width: 48, height: 48)
                            .background(
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                    }
                    if let additionalCount {
                        Text("+\(additionalCount)")
                            .font(.bodyRegular)
                            .foregroundStyle(STResourcesAsset.Colors.greenContrast.swiftUIColor)
                            .frame(width: 48, height: 48)
                            .background(
                                STResourcesAsset.Colors.greenDark.swiftUIColor
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            STResourcesAsset.Images.chevronRight.swiftUIImage
                .resizable()
                .frame(width: 16, height: 16)
        }
        .padding(16)
        .background(
            STResourcesAsset.Colors.greyPolarBear.swiftUIColor
                .clipShape(RoundedRectangle(cornerRadius: 16))
        )
    }
}

#Preview {
    VStack {
        SentItemView(itemCount: 2)
        SentItemView(itemCount: 6)
    }
}
