/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2024 Infomaniak Network SA

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
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct TransferDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isCompactWindow) private var isCompactWindow
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var multipleSelectionManager: MultipleSelectionManager
    @EnvironmentObject private var mainViewState: MainViewState

    private let transfer: TransferUi?

    private var matomoCategory: MatomoCategory {
        transfer?.direction == .received ? .receivedTransfer : .sentTransfer
    }

    private var shouldDisplayRecipientsOrMessage: Bool {
        let shouldDisplayRecipients = transfer?.recipientsEmails.isEmpty == false
        let shouldDisplayMessage = transfer?.trimmedMessage != nil && transfer?.trimmedMessage?.isEmpty == false
        return shouldDisplayRecipients || shouldDisplayMessage
    }

    public init(transfer: TransferUi?) {
        self.transfer = transfer
    }

    private var reportURL: URL? {
        guard let transfer else { return nil }

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

    private var menuItems: some View {
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

            if let transfer {
                Button(role: .destructive) {
                    deleteTransferLocally(transfer)
                } label: {
                    Label {
                        Text("Supprimer ce transfer")
                    } icon: {
                        STResourcesAsset.Images.delete.swiftUIImage
                    }
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

    public var body: some View {
        ScrollView {
            if let transfer {
                VStack(alignment: .leading, spacing: IKPadding.large) {
                    HeaderView(
                        filesCount: transfer.files.count,
                        transferSize: transfer.sizeUploaded,
                        expiringTimestamp: transfer.expirationDateTimestamp,
                        downloadLeft: transfer.downloadLeft,
                        downloadLimit: transfer.downloadLimit,
                        shouldShowDownloadCounter: transfer.direction == .sent && transfer.apiSource == .v1
                    )

                    if shouldDisplayRecipientsOrMessage {
                        VStack(alignment: .leading, spacing: IKPadding.medium) {
                            if !transfer.recipientsEmails.isEmpty {
                                RecipientsView(recipients: Array(transfer.recipientsEmails))
                            }
                            if let trimmedMessage = transfer.trimmedMessage, !trimmedMessage.isEmpty {
                                MessageView(message: trimmedMessage)
                            }
                        }
                    }

                    ContentView(transfer: transfer, matomoCategory: matomoCategory)
                }
                .padding(.vertical, value: .large)
                .padding(.horizontal, value: .medium)
                .shareTransferToolbar(transfer: transfer, matomoCategory: matomoCategory)
            } else {
                ProgressView()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .appBackground()
        .stNavigationBarStyle()
        .stNavigationBarMultipleSelection(
            title: transfer?.name ?? "",
            showCloseButton: isCompactWindow,
            isSelectAllEnabled: multipleSelectionManager.selectedItems.count < transfer?.files.count ?? 0
        ) {
            multipleSelectionManager.selectAll(files: transfer?.files)
        }
        .toolbar { transfer?.direction == .received ? menuItems : nil }
        .navigationDestination(for: FileUi.self) { file in
            if let transfer {
                FileListView(
                    folder: file,
                    transfer: transfer,
                    fileManager: mainViewState.swissTransferManager.fileManager,
                    matomoCategory: matomoCategory
                )
                .downloadSelectionToolbar(transfer: transfer)
                .environment(\.dismissModal) { dismiss() }
            }
        }
        .environment(\.dismissModal) { dismiss() }
        .matomoView(view: transfer?.direction == .sent ? .sentTransferDetails : .receivedTransferDetails)
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

#Preview {
    TransferDetailsView(transfer: PreviewHelper.sampleTransfer)
}
