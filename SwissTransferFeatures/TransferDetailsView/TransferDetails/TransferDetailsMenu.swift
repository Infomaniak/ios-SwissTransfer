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

    private var actionsByDirection: [MoreActions] {
        transfer.direction == .received ? [.report, .delete] : [.delete]
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
            ForEach(actionsByDirection, id: \.self) { action in
                Button(role: action.role) {
                    handle(action)
                } label: {
                    Label {
                        Text(action.title)
                    } icon: {
                        action.icon
                    }
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

    private func handle(_ action: MoreActions) {
        switch action {
        case .report:
            @InjectService var matomo: MatomoUtils
            matomo.track(eventWithCategory: .receivedTransfer, name: .reportTransfer)
            if let reportURL { openURL(reportURL) }
        case .delete:
            @InjectService var matomo: MatomoUtils
            matomo.track(eventWithCategory: .deleteTransferHistory, name: .transferDetailsMenu)
            mainViewState.isShowingDeleteTransferConfirmation = transfer
        }
    }
}

enum MoreActions: CaseIterable, Identifiable {
    var id: Self { self }

    case report
    case delete

    var title: String {
        switch self {
        case .report: STResourcesStrings.Localizable.reportTransfer
        case .delete: STResourcesStrings.Localizable.buttonDeleteTransfer
        }
    }

    var icon: Image {
        switch self {
        case .report: STResourcesAsset.Images.warning.swiftUIImage
        case .delete: STResourcesAsset.Images.bin.swiftUIImage
        }
    }

    var role: ButtonRole? {
        switch self {
        case .delete: .destructive
        case .report: nil
        }
    }
}
