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

    private var reportButton: some View {
        Button {
            @InjectService var matomo: MatomoUtils
            matomo.track(eventWithCategory: .receivedTransfer, name: .reportTransfer)
            if let reportURL { openURL(reportURL) }
        } label: {
            Label {
                Text(STResourcesStrings.Localizable.reportTransfer)
            } icon: {
                STResourcesAsset.Images.warning.swiftUIImage
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            @InjectService var matomo: MatomoUtils
            matomo.track(eventWithCategory: .deleteTransferHistory, name: .transferDetailsMenu)
            mainViewState.isShowingDeleteTransferConfirmation = transfer
        } label: {
            Label {
                Text(STResourcesStrings.Localizable.buttonDeleteTransfer)
            } icon: {
                STResourcesAsset.Images.bin.swiftUIImage
            }
        }
    }

    public var body: some View {
        if transfer.direction == .received {
            Menu {
                reportButton
                deleteButton
            } label: {
                Label {
                    Text(STResourcesStrings.Localizable.moreButton)
                } icon: {
                    STResourcesAsset.Images.plusActions.swiftUIImage
                }
            }
        } else {
            deleteButton
        }
    }
}
