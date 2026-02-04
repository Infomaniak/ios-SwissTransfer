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
import STResources
import SwiftUI
import SwissTransferCore

public struct AccountHeaderView: View {
    let user: UserProfile?

    public var body: some View {
        VStack(spacing: IKPadding.micro) {
            STResourcesAsset.Images.user.swiftUIImage
                .foregroundStyle(Color.ST.onRecipientLabelBackground)
                .frame(width: 80, height: 80)
                .background(Color.ST.highlighted, in: .circle)
                .padding(IKPadding.small)

            Text(user?.displayName ?? "Mon compte")
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)
                .multilineTextAlignment(.center)

            if let user = user {
                Text(user.email)
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    AccountHeaderView(user: PreviewHelper.sampleUser)
}
