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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var mainViewState: MainViewState

    private let transfer: TransferUi

    public init(transfer: TransferUi) {
        self.transfer = transfer
    }

    private var reportURL: URL? {
        let apiURLCreator = mainViewState.swissTransferManager.sharedApiUrlCreator
        let transferLink: String

        if transfer.apiSource == .v1 {
            transferLink = apiURLCreator.shareTransferUrl(transferUUID: transfer.uuid)
        } else if let linkId = transfer.linkId {
            transferLink = apiURLCreator.shareTransferV2Url(linkUUID: linkId)
        } else {
            return nil
        }

        var components = URLComponents(
            string: "https://www.infomaniak.com/fr/report_abuse"
        )
        components?.queryItems = [
            URLQueryItem(name: "from", value: "swisstransfer"),
            URLQueryItem(name: "url", value: transferLink)
        ]
        return components?.url
    }

    public var body: some View {
        Menu {
            if let reportURL {
                Button {
                    openURL(reportURL)
                } label: {
                    Label {
                        Text("Signaler ce transfert")
                    } icon: {
                        STResourcesAsset.Images.arrowDownCircle.swiftUIImage
                    }
                }
            }

            Button(role: .destructive) {
                deleteTransferLocally(transfer)
            } label: {
                Label {
                    Text("Supprimer ce transfer")
                } icon: {
                    STResourcesAsset.Images.delete.swiftUIImage
                }
            }
        } label: {
            Label {
                Text("More")
            } icon: {
                STResourcesAsset.Images.plus.swiftUIImage
            }
        }
    }

    private func deleteTransferLocally(_ transfer: TransferUi) {
        Task {
            try? await mainViewState.transferManager.deleteTransfer(transferUUID: transfer.uuid)
            transfer.removeLocalContainer()
        }

        // TODO: Replace matomoName
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: .deleteTransferHistory, name: MatomoName.deleteFile)

        dismiss()
    }
}
