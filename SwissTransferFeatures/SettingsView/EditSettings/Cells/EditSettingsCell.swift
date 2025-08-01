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
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI

struct EditSettingCell: View {
    let selected: Bool
    let label: String
    var leftImage: Image?
    let matomoCategory: MatomoCategory
    let matomoName: MatomoName
    let action: () -> Void

    var body: some View {
        Button {
            @InjectService var matomo: MatomoUtils
            matomo.track(eventWithCategory: matomoCategory, name: matomoName)
            action()
        } label: {
            HStack(spacing: IKPadding.small) {
                if let leftImage {
                    leftImage
                        .iconSize(.large)
                }

                Text(label)
                    .lineLimit(1)
                    .foregroundStyle(Color.ST.textPrimary)
                    .font(.ST.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if selected {
                    Image(asset: STResourcesAsset.Images.check)
                        .iconSize(.medium)
                        .foregroundColor(Color.ST.primary)
                }
            }
        }
    }
}

#Preview {
    EditSettingCell(selected: true, label: "EditSettingsView", matomoCategory: .settingsGlobalTheme, matomoName: .light) {
        print("EditSettingsView action")
    }
}
