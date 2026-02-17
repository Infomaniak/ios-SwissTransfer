/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

struct MultipleSelectionCheckboxView: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .foregroundStyle(isSelected ? STResourcesAsset.Colors.greenMain.swiftUIColor : STResourcesAsset.Colors.white
                    .swiftUIColor)
                .frame(width: 16, height: 16)

            if !isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(STResourcesAsset.Colors.greyShark.swiftUIColor)
                    .frame(width: 16, height: 16)
            } else {
                STResourcesAsset.Images.check.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 16, height: 16)
    }
}

#Preview {
    VStack {
        MultipleSelectionCheckboxView(isSelected: false)
        MultipleSelectionCheckboxView(isSelected: true)
    }
}
