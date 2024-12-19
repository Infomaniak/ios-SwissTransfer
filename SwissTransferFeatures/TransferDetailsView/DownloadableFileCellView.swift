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
    @LazyInjectService private var downloadManager: DownloadManager

    @State private var progress: Double?
    @State private var downloadTask: Task<Void, any Error>?
    @State private var downloadedFilePreviewURL: URL?
    @State private var downloadedDirectoryURL: IdentifiableURL?

    let transfer: TransferUi
    let file: FileUi

    var body: some View {
        Button(action: download) {
            LargeFileCell(
                fileName: file.fileName,
                fileSize: file.fileSize,
                url: file.localURL,
                mimeType: file.mimeType ?? ""
            )
            .overlay {
                if let progress {
                    ProgressView(value: progress)
                        .progressViewStyle(.circularDeterminate)
                        .frame(width: 20, height: 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(value: .small)
                }
            }
        }
        .buttonStyle(.plain)
        .quickLookPreview($downloadedFilePreviewURL)
        .sheet(item: $downloadedDirectoryURL) { downloadedFileURL in
            ActivityView(sharedFileURL: downloadedFileURL.url)
        }
    }

    private func download() {
        if let downloadTask {
            downloadTask.cancel()
            reset()
        } else {
            downloadTask = Task {
                do {
                    let downloadedURL = try await downloadManager.download(file: file, in: transfer) { progress in
                        Task { @MainActor in
                            guard let downloadTask, !downloadTask.isCancelled else { return }

                            withAnimation {
                                self.progress = progress
                            }
                        }
                    }

                    if file.isFolder {
                        downloadedDirectoryURL = IdentifiableURL(url: downloadedURL)
                    } else {
                        downloadedFilePreviewURL = downloadedURL
                    }
                } catch {
                    Logger.general.error("Error downloading transfer: \(error)")
                    // TODO: Display the error someway ?
                }
                reset()
            }
        }
    }

    private func reset() {
        withAnimation {
            self.downloadTask = nil
            self.progress = nil
        }
    }
}

#Preview {
    DownloadableFileCellView(transfer: PreviewHelper.sampleTransfer, file: PreviewHelper.sampleFile)
}
