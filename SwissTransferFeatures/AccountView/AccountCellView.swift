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

import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakDI
import InfomaniakLogin
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct AccountCellView: View {
    @Environment(\.dismissModal) private var dismissModal

    @Binding var selectedUserId: Int?

    let user: InfomaniakCore.UserProfile

    private var isSelected: Bool {
        return selectedUserId == user.id
    }

    var body: some View {
        Button {
            guard !isSelected else { return }

        } label: {
            AccountHeaderCell(user: user, isSelected: Binding(get: {
                isSelected
            }, set: {
                selectedUserId = $0 ? user.id : nil
            }))
        }
    }
}

struct AccountHeaderCell: View {
    let user: InfomaniakCore.UserProfile

    @Binding var isSelected: Bool

    var body: some View {
        HStack {
            AvatarView(user: user, avatarSize: 40)
            VStack(alignment: .leading, spacing: 0) {
                Text(user.displayName)
                    .font(.ST.headline)
                    .foregroundStyle(Color.ST.textPrimary)
                Text(user.email)
                    .font(.ST.headline)
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            if isSelected {
                STResourcesAsset.Images.check.swiftUIImage
                    .iconSize(.medium)
                    .foregroundStyle(.tint)
            }
        }
        .padding(.vertical, value: .mini)
    }
}

#Preview {
    AccountCellView(
        selectedUserId: .constant(nil),
        user: PreviewHelper.sampleUser
    )
}
