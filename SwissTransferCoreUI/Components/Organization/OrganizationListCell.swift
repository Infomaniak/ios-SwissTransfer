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
import MyKSuite
import STCore
import STResources
import SwiftUI

struct OrganizationCellView: View {
    let organization: STDOrganizationAccount
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                OrganizationAvatarView(organization: organization)

                VStack(alignment: .leading, spacing: 0) {
                    Text(organization.name)
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textPrimary)
                        .lineLimit(1)

                    if let type = OrganizationType(type: organization.type, pack: organization.pack) {
                        type.label
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    STResourcesAsset.Images.check.swiftUIImage
                        .iconSize(.medium)
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

enum OrganizationType {
    case ksuite(pack: String)
    case myKSuite(pack: MyKSuitePack)

    enum MyKSuitePack: String {
        case myKSuite = "my_ksuite"
        case myKSuitePlus = "my_ksuite_plus"

        var image: Image {
            switch self {
            case .myKSuite:
                return MyKSuiteResources.myKSuiteLogo.swiftUIImage
            case .myKSuitePlus:
                return MyKSuiteResources.myKSuitePlusLogo.swiftUIImage
            }
        }
    }

    init?(type: String, pack: String) {
        switch type {
        case "ksuite":
            self = .ksuite(pack: pack)
        case "my_ksuite":
            let myKSuitePack = MyKSuitePack(rawValue: pack) ?? .myKSuite
            self = .myKSuite(pack: myKSuitePack)
        default:
            return nil
        }
    }

    var label: some View {
        switch self {
        case .ksuite(let pack):
            return AnyView(
                Text(pack.capitalized)
                    .font(.ST.callout)
                    .foregroundStyle(Color.ST.textSecondary)
                    .lineLimit(1)
            )
        case .myKSuite(let pack):
            return AnyView(pack.image)
        }
    }
}
