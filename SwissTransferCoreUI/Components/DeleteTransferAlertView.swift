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
import InfomaniakCoreSwiftUI
import InfomaniakCoreUIResources
import InfomaniakDI
import STResources
import SwiftUI
import SwissTransferCore

public struct DeleteTransferAlertView: View {
    @LazyInjectService private var accountManager: SwissTransferCore.AccountManager
    @EnvironmentObject private var universalLinksState: UniversalLinksState

    private let deleteLink: DeleteTransferLinkResult

    public init(deleteLink: DeleteTransferLinkResult) {
        self.deleteLink = deleteLink
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(STResourcesStrings.Localizable.deleteThisTransferTitle)
                .padding(.bottom, IKPadding.large)
                .font(.ST.headline)
                .foregroundStyle(Color.ST.textPrimary)
            Text(STResourcesStrings.Localizable.deleteThisTransferDescription)
                .padding(.bottom, IKPadding.large)
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)

            ModalButtonsView(
                primaryButtonTitle: STResourcesStrings.Localizable.buttonDeleteYes,
                secondaryButtonTitle: CoreUILocalizable.buttonCancel,
                primaryButtonAction: {
                    handleDelete()
                    universalLinksState.linkedDeleteTransfer = nil
                },
                secondaryButtonAction: {
                    universalLinksState.linkedDeleteTransfer = nil
                },
                primaryButtonRole: .destructive
            )
            .padding(.leading)
        }
    }

    private func handleDelete() {
        Task {
            let defaultTransferManager = await accountManager.getCurrentManager()
            try? await defaultTransferManager?.deleteTransfer(transferUUID: deleteLink.uuid, token: deleteLink.token)
        }
    }
}

#Preview {
    DeleteTransferAlertView(deleteLink: DeleteTransferLinkResult(uuid: "", token: ""))
}
