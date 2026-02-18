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

import InfomaniakCoreCommonUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

extension View {
    func deleteLocalTransferSafeAreaButton(transfer: TransferUi?, origin: DeleteLocalTransferViewModifier.Origin) -> some View {
        modifier(DeleteLocalTransferViewModifier(transfer: transfer, origin: origin))
    }
}

struct DeleteLocalTransferViewModifier: ViewModifier {
    enum Origin {
        case virusDetected
        case expiredDate
        case expiredDownloads

        var matomoName: MatomoName {
            switch self {
            case .virusDetected:
                return .virusDetected
            case .expiredDate:
                return .expiredDate
            case .expiredDownloads:
                return .expiredDownloads
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var mainViewState: MainViewState

    let transfer: TransferUi?
    let origin: Origin

    func body(content: Content) -> some View {
        content
            .safeAreaButtons {
                if let transfer {
                    Button(STResourcesStrings.Localizable.buttonDeleteTransfer) {
                        deleteTransferLocally(transfer)
                    }
                    .buttonStyle(.ikBorderedProminent)
                }
            }
    }

    private func deleteTransferLocally(_ transfer: TransferUi) {
        Task {
            try? await mainViewState.transferManager.deleteTransfer(transferUUID: transfer.uuid)
            transfer.removeLocalContainer()
        }

        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: .deleteTransferHistory, name: origin.matomoName)

        dismiss()
    }
}
