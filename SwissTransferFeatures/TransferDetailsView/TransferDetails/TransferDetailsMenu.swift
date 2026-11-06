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

public struct TransferDetailsMenu: View {
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var mainViewState: MainViewState

    private let transfer: TransferUi

    public init(transfer: TransferUi) {
        self.transfer = transfer
    }

    private var reportURL: URL? {
        let urlString = mainViewState.swissTransferManager.sharedApiUrlCreator
            .reportTransferUrl(transfer: transfer)

        return URL(string: urlString)
    }

    public var body: some View {
        Menu {
            if let reportURL {
                Button {
                    @InjectService var matomo: MatomoUtils
                    matomo.track(eventWithCategory: .receivedTransfer, name: .reportTransfer)

                    openURL(reportURL)
                } label: {
                    Label {
                        Text(STResourcesStrings.Localizable.reportTransfer)
                    } icon: {
                        STResourcesAsset.Images.warning.swiftUIImage
                            .foregroundStyle(.black)
                    }
                }
            }

            Button(role: .destructive) {
                deleteTransferLocally(transfer)
            } label: {
                Label {
                    Text(STResourcesStrings.Localizable.buttonDeleteTransfer)
                } icon: {
                    STResourcesAsset.Images.bin.swiftUIImage
                }
            }
        } label: {
            Label {
                Text(STResourcesStrings.Localizable.moreButton)
            } icon: {
                STResourcesAsset.Images.plusActions.swiftUIImage
            }
        }
    }

    private func deleteTransferLocally(_ transfer: TransferUi) {
        Task {
            try? await mainViewState.transferManager.deleteTransfer(transferUUID: transfer.uuid)
            transfer.removeLocalContainer()
        }

        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: .deleteTransferHistory, name: .transferDetailsMenu)

        mainViewState.selectedDestination = nil
    }
}
