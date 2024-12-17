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
    private let transfer: TransferUi

    public init(transfer: TransferUi) {
        self.transfer = transfer
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: IKPadding.large) {
                    HeaderView(
                        filesCount: transfer.files.count,
                        transferSize: transfer.sizeUploaded,
                        expiringTimestamp: transfer.expirationDateTimestamp
                    )

                    if let trimmedMessage = transfer.trimmedMessage, !trimmedMessage.isEmpty {
                        MessageView(message: trimmedMessage)
                    }

                    ContentView(files: transfer.files)
                }
                .padding(.vertical, value: .large)
                .padding(.horizontal, value: .medium)
            }
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(transfer.name)
                        .font(.ST.title2)
                        .foregroundStyle(.white)
                }
            }
            .stNavigationBarStyle()
            .navigationDestination(for: FileUi.self) { file in
                // Get children of file using func in a stash
                // Find a way to use FileList and ContentView
                FileListView(folder: file)
            }
            ToolbarItem(placement: .primaryAction) {
                DownloadButton(transfer: transfer)
            }
        }
    }
}

#Preview {
    TransferDetailsView(transfer: PreviewHelper.sampleTransfer)
}
