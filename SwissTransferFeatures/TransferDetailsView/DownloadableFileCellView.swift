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

import InfomaniakDI
import OSLog
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct DownloadableFileCellView: View {
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var downloadedFilePreviewURL: URL?
    @State private var downloadedDirectoryURL: IdentifiableURL?

    let transfer: TransferUi
    let file: FileUi

    var body: some View {
        Button(action: startOrCancelDownloadIfNeeded) {
            LargeFileCell(
                fileName: file.fileName,
                fileSize: file.fileSize,
                url: file.localURL(in: transfer),
                mimeType: file.mimeType ?? ""
            )
        }
        .buttonStyle(.plain)
        .downloadProgressAlertFor(transfer: transfer, file: file) { downloadedFileURL in
            presentFile(at: downloadedFileURL)
        }
        .quickLookPreview($downloadedFilePreviewURL)
        .sheet(item: $downloadedDirectoryURL) { downloadedFileURL in
            ActivityView(sharedFileURL: downloadedFileURL.url)
        }
    }

    private func startOrCancelDownloadIfNeeded() {
        Task {
            if let downloadTask = downloadManager.getDownloadTaskFor(file: file, in: transfer) {
                await downloadManager.removeDownloadTask(id: downloadTask.id)
                return
            }

            if let localURL = file.localURL(in: transfer),
               FileManager.default.fileExists(atPath: localURL.path()) {
                presentFile(at: localURL)
                return
            }

            try await downloadManager.startDownload(file: file, in: transfer)
        }
    }

    private func presentFile(at url: URL) {
        if file.isFolder {
            downloadedDirectoryURL = IdentifiableURL(url: url)
        } else {
            downloadedFilePreviewURL = url
        }
    }
}

#Preview {
    DownloadableFileCellView(transfer: PreviewHelper.sampleTransfer, file: PreviewHelper.sampleFile)
}
