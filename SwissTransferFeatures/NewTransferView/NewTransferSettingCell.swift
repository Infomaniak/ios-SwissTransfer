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

struct NewTransferSettingCell: View {
    let title: String
    let icon: Image
    let value: String
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Label {
                    Text(title)
                        .font(.ST.calloutMedium)
                        .foregroundStyle(Color.ST.primary)
                } icon: {
                    icon
                        .iconSize(.medium)
                }
                .labelStyle(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: IKPadding.small) {
                    Text(value)
                        .font(.ST.callout)

                    STResourcesAsset.Images.chevronRight.swiftUIImage
                        .iconSize(.medium)
                }
                .foregroundStyle(Color.ST.textSecondary)
            }
            .padding(.vertical, value: .small)
        }
    }
}

#Preview {
    NewTransferSettingCell(
        title: STResourcesStrings.Localizable.settingsOptionValidityPeriod,
        icon: STResourcesAsset.Images.clock.swiftUIImage,
        value: "selected"
    ) {}
}
