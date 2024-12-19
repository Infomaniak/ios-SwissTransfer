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
import STResources
import SwiftUI
import SwissTransferCore

struct ActivityView: UIViewControllerRepresentable {
    let sharedFileURL: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [sharedFileURL], applicationActivities: nil)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}
}

struct IdentifiableURL: Identifiable {
    var id: String {
        url.absoluteString
    }

    let url: URL
}

struct DownloadButton: View {
    @LazyInjectService private var downloadManager: DownloadManager

    @State private var progress: Double?
    @State private var downloadTask: Task<Void, any Error>?
    @State private var downloadedFileURL: IdentifiableURL?

    let transfer: TransferUi
    var file: FileUi?

    var body: some View {
        Button(action: download) {
            if let progress {
                CircleProgressView(progress: progress)
            } else {
                Label(
                    title: {
                        Text(STResourcesStrings.Localizable.buttonDownload)
                    },
                    icon: { STResourcesAsset.Images.arrowDownLine.swiftUIImage }
                )
                .labelStyle(.iconOnly)
            }
        }
        .sheet(item: $downloadedFileURL) { downloadedFileURL in
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
                    let downloadedURL: URL
                    if let file {
                        downloadedURL = try await downloadManager.download(file: file, in: transfer) { progress in
                            Task { @MainActor in
                                handleProgress(progress)
                            }
                        }
                    } else {
                        downloadedURL = try await downloadManager.download(transfer: transfer) { progress in
                            Task { @MainActor in
                                handleProgress(progress)
                            }
                        }
                    }

                    downloadedFileURL = IdentifiableURL(url: downloadedURL)
                } catch {
                    Logger.general.error("Error downloading transfer: \(error)")
                    // TODO: Display the error someway ?
                }
                reset()
            }
        }
    }

    private func handleProgress(_ progress: Double) {
        guard let downloadTask, !downloadTask.isCancelled else { return }
        withAnimation {
            self.progress = progress
        }
    }

    private func reset() {
        withAnimation {
            self.downloadTask = nil
            self.progress = nil
        }
    }
}
