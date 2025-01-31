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

import DesignSystem
import InfomaniakCoreSwiftUI
import STCore
import STResources
import SwiftUI
import SwissTransferCore

struct SettingSelectableCell<T: SettingSelectable>: View {
    let item: T
    let selectedItem: T

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            HStack(spacing: IKPadding.medium) {
                Label {
                    Text(item.title)
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textPrimary)
                } icon: {
                    item.leftImage
                }
                .labelStyle(.ikLabel(IKPadding.medium))
                .frame(maxWidth: .infinity, alignment: .leading)

                if selectedItem == item {
                    STResourcesAsset.Images.check.swiftUIImage
                        .foregroundStyle(Color.ST.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(value: .medium)
        }
    }
}

#Preview {
    SettingSelectableCell(item: ValidityPeriod.one, selectedItem: ValidityPeriod.thirty)
}
