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

import InfomaniakCoreCommonUI
import InfomaniakDI
import OSLog
import STCore
import SwiftUI
import SwissTransferCore

struct DownloadableFileCellView: View {
    @LazyInjectService private var notificationsHelper: NotificationsHelper

    @EnvironmentObject private var downloadManager: DownloadManager

    let transfer: TransferUi
    let file: FileUi
    let isMultiSelectionEnabled: Bool
    @Binding var isSelected: Bool
    let matomoCategory: MatomoCategory

    private var downloadFileAction: DownloadFileAction {
        DownloadFileAction { _ in
            downloadManager.startOrCancelDownload(transfer: transfer, files: [file], matomoCategory: matomoCategory)
        }
    }

    var body: some View {
        ZStack {
            if file.isFolder && !isMultiSelectionEnabled {
                LargeFileCell(file: file, transferUUID: transfer.uuid, action: downloadFileAction)
            } else {
                LargeFileCell(file: file, transferUUID: transfer.uuid, action: downloadFileAction)
                    .onTapGesture {
                        fileTapped()
                    }
            }
            if isMultiSelectionEnabled {
                MultipleSelectionCheckboxView(isSelected: isSelected)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(12)
            }
        }
    }

    private func fileTapped() {
        guard isMultiSelectionEnabled else {
            downloadManager.startOrCancelDownload(transfer: transfer, files: [file], matomoCategory: matomoCategory)
            return
        }

        isSelected.toggle()
    }
}

#Preview {
    DownloadableFileCellView(
        transfer: PreviewHelper.sampleTransfer,
        file: PreviewHelper.sampleFile,
        isMultiSelectionEnabled: false,
        isSelected: .constant(false),
        matomoCategory: .sentTransfer
    )
}
