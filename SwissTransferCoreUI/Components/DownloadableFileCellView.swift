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

    @State private var downloadedFilePreviewURL: URL?
    @State private var downloadedDirectoryURL: IdentifiableURL?

    let transfer: TransferUi
    let file: FileUi
    let isMultiSelectionEnabled: Bool
    @Binding var isSelected: Bool
    let matomoCategory: MatomoCategory

    private var downloadFileAction: DownloadFileAction {
        DownloadFileAction { _ in
            startOrCancelDownloadIfNeeded()
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
        // TODO: - Monter ca dans TransferDetailsView
        .downloadProgressAlertFor(transfer: transfer, files: [file]) { downloadedFileURLs in
            print("simple completion done")
            // TODO: - Temporary
            // Temporary
            guard let firstUrl = downloadedFileURLs.first else { return }
            presentFile(at: firstUrl)
        }
        .quickLookPreview($downloadedFilePreviewURL)
        .sheet(item: $downloadedDirectoryURL) { downloadedFileURL in
            ActivityView(sharedFileURLs: [downloadedFileURL.url])
        }
    }

    private func startOrCancelDownloadIfNeeded() {
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: matomoCategory, name: .consultOneFile)
        print("Start")

        Task {
            if let downloadTask = downloadManager.getDownloadTaskFor(transfer: transfer, file: file) {
//                await downloadManager.removeDownloadTask(id: downloadTask.id)
                await downloadManager.removeMultiDownloadTask()
                return
            }

            if let localURL = file.localURLFor(transfer: transfer),
               FileManager.default.fileExists(atPath: localURL.path()) {
                print("inside local url")
                presentFile(at: localURL)
                return
            }

            Task {
                await notificationsHelper.requestPermissionIfNeeded()
            }

            try await downloadManager.startDownload(files: [file], in: transfer)
        }
    }

    private func presentFile(at url: URL) {
        if file.isFolder {
            downloadedDirectoryURL = IdentifiableURL(url: url)
        } else {
            downloadedFilePreviewURL = url
        }
    }

    private func fileTapped() {
        guard isMultiSelectionEnabled else {
            startOrCancelDownloadIfNeeded()
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
