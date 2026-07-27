/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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
import InfomaniakDI
import MyKSuite
import NukeUI
import STCore
import STResources
import SwiftUI
import SwissTransferCore

struct OrganizationCellView: View {
    let organization: STDOrganizationAccount
    let isSelected: Bool

    let action: () -> Void

    private var uppercasedOrganizationPack: String {
        if var first = organization.pack.first {
            first = first.uppercased().first!
            return String(first) + organization.pack.dropFirst()
        }
        return ""
    }

    var body: some View {
        Button(action: action) {
            HStack {
                OrganizationAvatarView(organization: organization)
                VStack(alignment: .leading, spacing: 0) {
                    Text(organization.name)
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textPrimary)
                        .lineLimit(1)

                    if organization.type == "ksuite" {
                        Text(uppercasedOrganizationPack)
                            .font(.ST.callout)
                            .foregroundStyle(Color.ST.textSecondary)
                            .lineLimit(1)
                    } else if organization.type == "my_ksuite" {
                        if organization.pack == "my_ksuite" {
                            MyKSuiteResources.myKSuiteLogo.swiftUIImage
                        } else if organization.pack == "my_ksuite_plus" {
                            MyKSuiteResources.myKSuitePlusLogo.swiftUIImage
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    STResourcesAsset.Images.check.swiftUIImage
                        .iconSize(.medium)
                        .foregroundStyle(.tint)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, value: .mini)
        }
    }
}
