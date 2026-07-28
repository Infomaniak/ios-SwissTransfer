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

import DesignSystem
import InfomaniakCore
import InfomaniakCoreSwiftUI
import NukeUI
import STCore
import SwiftUI

public struct OrganizationAvatarView: View {
    let organization: STDOrganizationAccount
    private let avatarSize: CGFloat

    public init(organization: STDOrganizationAccount, avatarSize: CGFloat = 40) {
        self.organization = organization
        self.avatarSize = avatarSize
    }

    public var body: some View {
        ZStack {
            if let logoUrl = organization.logoUrl, let url = URL(string: logoUrl) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        OrganizationImage(image: image, size: avatarSize)
                    } else {
                        initialsView
                    }
                }
            } else {
                initialsView
            }
            RoundedRectangle(cornerRadius: IKRadius.small)
                .stroke(Color.ST.cardBorder, lineWidth: 1)
        }
        .frame(width: avatarSize, height: avatarSize)
    }

    private var initialsView: some View {
        OrganizationInitialsView(
            initials: NameFormatter(fullName: organization.name).initials,
            backgroundColor: Color.backgroundColor(from: organization.name.hash),
            foregroundColor: Color.white,
            size: avatarSize
        )
    }
}
