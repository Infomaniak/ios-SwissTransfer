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

import InfomaniakCoreSwiftUI
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct TransferDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    private let transfer: TransferUi

    public init(transfer: TransferUi) {
        self.transfer = transfer
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: IKPadding.large) {
                HeaderView(
                    filesCount: transfer.files.count,
                    transferSize: transfer.sizeUploaded,
                    expiringTimestamp: transfer.expirationDateTimestamp,
                    downloadLeft: transfer.downloadLeft,
                    downloadLimit: transfer.downloadLimit
                )

                if let trimmedMessage = transfer.trimmedMessage, !trimmedMessage.isEmpty {
                    MessageView(message: trimmedMessage)
                }

                ContentView(transfer: transfer)
            }
            .padding(.vertical, value: .large)
            .padding(.horizontal, value: .medium)
        }
        .shareTransferToolbar(transfer: transfer)
        .toolbarBackground(.visible, for: .bottomBar)
        .appBackground()
        .stNavigationBarFullScreen(title: transfer.name)
        .navigationDestination(for: FileUi.self) { file in
            FileListView(folder: file, transfer: transfer)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                DownloadButton(transfer: transfer)
            }
        }
        .environment(\.dismissModal) { dismiss() }
    }
}

#Preview {
    TransferDetailsView(transfer: PreviewHelper.sampleTransfer)
}
