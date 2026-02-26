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
    @EnvironmentObject private var downloadManager: DownloadManager
    @EnvironmentObject private var multipleSelectionManager: MultipleSelectionManager
    @EnvironmentObject private var mainViewState: MainViewState

    @State private var downloadedFilePreviewURL: URL?
    @State private var downloadedDirectoryURL: IdentifiableURL?

    let transfer: TransferUi
    let file: FileUi
    let matomoCategory: MatomoCategory

    private var downloadFileAction: DownloadFileAction? {
        guard !multipleSelectionManager.isEnabled else {
            return nil
        }

        return DownloadFileAction { _ in
            downloadManager.startOrCancelDownload(
                transfer: transfer,
                files: [file],
                sharedApiUrlCreator: mainViewState.swissTransferManager.sharedApiUrlCreator,
                matomoCategory: matomoCategory
            )
        }
    }

    var body: some View {
        Group {
            if file.isFolder && !multipleSelectionManager.isEnabled {
                LargeFileCell(file: file, transferUUID: transfer.uuid, action: downloadFileAction)
            } else {
                LargeFileCell(file: file, transferUUID: transfer.uuid, action: downloadFileAction)
                    .onTapGesture {
                        fileTapped()
                    }
                    .overlay(alignment: .topLeading) {
                        if multipleSelectionManager.isEnabled {
                            MultipleSelectionCheckboxView(isSelected: multipleSelectionManager.isSelected(file: file))
                                .padding(12)
                        }
                    }
            }
        }
        .onLongPressGesture {
            multipleSelectionManager.toggleMultipleSelection(of: file)
        }
    }

    private func fileTapped() {
        guard multipleSelectionManager.isEnabled else {
            downloadManager.startOrCancelDownload(
                transfer: transfer,
                files: [file],
                sharedApiUrlCreator: mainViewState.swissTransferManager.sharedApiUrlCreator,
                matomoCategory: matomoCategory
            )
            return
        }

        multipleSelectionManager.toggleSelection(of: file)
    }
}

#Preview {
    DownloadableFileCellView(
        transfer: PreviewHelper.sampleTransfer,
        file: PreviewHelper.sampleFile,
        matomoCategory: .sentTransfer
    )
}
