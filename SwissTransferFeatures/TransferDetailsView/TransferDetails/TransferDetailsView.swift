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
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct TransferDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isCompactWindow) private var isCompactWindow

    @StateObject private var multipleSelectionViewModel = MultipleSelectionViewModel()

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
                        transferDirection: transfer.direction
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

                    ContentView(transfer: transfer, multipleSelectionViewModel: multipleSelectionViewModel, matomoCategory: matomoCategory)
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
        .stNavigationBarFullScreen(title: transfer?.name ?? "", showCloseButton: isCompactWindow)
        .navigationDestination(for: FileUi.self) { file in
            FileListView(folder: file, transfer: transfer, matomoCategory: matomoCategory)
                .environment(\.dismissModal) { dismiss() }
        }
        .environment(\.dismissModal) { dismiss() }
        .matomoView(view: transfer?.direction == .sent ? .sentTransferDetails : .receivedTransferDetails)
    }
}

#Preview {
    TransferDetailsView(transfer: PreviewHelper.sampleTransfer)
}
