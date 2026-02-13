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
import InfomaniakDI
import STResources
import SwiftUI
import SwissTransferCore

struct LogoutConfirmationView: View {
    let user: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(STResourcesStrings.Localizable.confirmLogoutTitle)
                .font(.ST.headline)
                .foregroundStyle(Color.ST.textPrimary)
                .padding(.bottom, IKPadding.large)
            Text(STResourcesStrings.Localizable.confirmLogoutDescription(user.email))
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)
                .padding(.bottom, IKPadding.large)
            ModalButtonsView(primaryButtonTitle: STResourcesStrings.Localizable.buttonConfirm, primaryButtonAction: logout)
        }
    }

    private func logout() async {
        @InjectService var accountManager: AccountManager
        await accountManager.removeTokenAndAccountFor(userId: user.id)
    }
}

#Preview {
    LogoutConfirmationView(user: PreviewHelper.sampleUser)
}
