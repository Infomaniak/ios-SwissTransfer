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
import InfomaniakCoreSwiftUI
import InfomaniakDI
import OSLog
import STCore
import STResources
import SwiftUI
import SwissTransferCore

struct DownloadResult: Identifiable {
    let id = UUID().uuidString
    let urls: [URL]
}

struct ActivityView: UIViewControllerRepresentable {
    let sharedFileURLs: [URL]

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: sharedFileURLs, applicationActivities: nil)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}
}

public struct DownloadButton: View {
    @LazyInjectService private var notificationsHelper: NotificationsHelper

    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var downloadedTransferURL: DownloadResult?
    @ObservedObject private var multipleSelectionViewModel: MultipleSelectionViewModel

    let transfer: TransferUi
    let matomoCategory: MatomoCategory

    public init(transfer: TransferUi, multipleSelectionViewModel: MultipleSelectionViewModel, matomoCategory: MatomoCategory) {
        self.transfer = transfer
        self.multipleSelectionViewModel = multipleSelectionViewModel
        self.matomoCategory = matomoCategory
    }

    public var body: some View {
        Button {
            download()
        } label: {
            Label {
                Text(STResourcesStrings.Localizable.buttonDownload)
            } icon: {
                STResourcesAsset.Images.arrowDownLine.swiftUIImage
            }
        }
        .downloadProgressAlertFor(transfer: transfer) { downloadedFileURLs in
            print("completion transfer")
            downloadedTransferURL = DownloadResult(urls: downloadedFileURLs)
        }
        .downloadProgressAlertFor(transfer: transfer, files: Array(multipleSelectionViewModel.selectedItems)) { downloadedFileURLs in
            print("completion multi \(downloadedFileURLs.count)")
            downloadedTransferURL = DownloadResult(urls: downloadedFileURLs)
        }
        .sheet(item: $downloadedTransferURL) { downloadResult in
            ActivityView(sharedFileURLs: downloadResult.urls)
        }
    }

    private func startOrCancelDownloadIfNeeded() {
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: matomoCategory, name: .downloadTransfer)

        Task {
            if let multiDownloadTask = downloadManager.getMultiDownloadTaskFor(transfer: transfer, files: []) {
//            if let downloadTask = downloadManager.getDownloadTaskFor(transfer: transfer) {
//                await downloadManager.removeDownloadTask(id: downloadTask.id)
                await downloadManager.removeMultiDownloadTask()
                return
            }

            if let localURL = transfer.localArchiveURL,
               FileManager.default.fileExists(atPath: localURL.path()) {
                downloadedTransferURL = DownloadResult(urls: [localURL]) // Changer ca c'est pas une liste
                return
            }

            Task {
                await notificationsHelper.requestPermissionIfNeeded()
            }

            try? await downloadManager.startDownload(transfer: transfer)
        }
    }

    // TODO: - Peut mieux faire
    /// Pour chaque file chercher si il est en local avant de download ?
    private func startOrCancelDownloadIfNeeded(files: [FileUi]) {
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: matomoCategory, name: .downloadTransfer)

        Task {
            // TODO: - C'est utile ca ?
            if downloadManager.getMultiDownloadTaskFor(transfer: transfer, files: files) != nil {
                await downloadManager.removeMultiDownloadTask()
                return
            }

            let localURLs: [URL] = files.compactMap {
                guard let localURL = $0.localURLFor(transfer: transfer),
                      FileManager.default.fileExists(atPath: localURL.path()) else { return nil }
                return localURL
            }

            print("local count: \(localURLs.count)")
            if localURLs.count == files.count {
                print("find all locally")
                downloadedTransferURL = DownloadResult(urls: localURLs)
                return
            }

            Task {
                await notificationsHelper.requestPermissionIfNeeded()
            }

            try? await downloadManager.startDownload(files: files, in: transfer)
        }
    }

    private func download() {
        if multipleSelectionViewModel.isEnabled {
            startOrCancelDownloadIfNeeded(files: Array(multipleSelectionViewModel.selectedItems))
        } else {
            startOrCancelDownloadIfNeeded()
        }
    }
}
