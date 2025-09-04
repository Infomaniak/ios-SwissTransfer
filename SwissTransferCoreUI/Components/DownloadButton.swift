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

public struct DownloadButton: View {
    @LazyInjectService private var notificationsHelper: NotificationsHelper

    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var downloadedTransferURL: IdentifiableURL?

    let transfer: TransferUi
    let matomoCategory: MatomoCategory

    public init(transfer: TransferUi, matomoCategory: MatomoCategory) {
        self.transfer = transfer
        self.matomoCategory = matomoCategory
    }

    public var body: some View {
        Button {
            startOrCancelDownloadIfNeeded()
        } label: {
            Label {
                Text(STResourcesStrings.Localizable.buttonDownload)
            } icon: {
                STResourcesAsset.Images.arrowDownLine.swiftUIImage
            }
        }
        .downloadProgressAlertFor(transfer: transfer) { downloadedFileURL in
            downloadedTransferURL = IdentifiableURL(url: downloadedFileURL)
        }
        .sheet(item: $downloadedTransferURL) { downloadedFileURL in
            ActivityView(sharedFileURL: downloadedFileURL.url)
        }
    }

    private func startOrCancelDownloadIfNeeded() {
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: matomoCategory, name: .downloadTransfer)

        Task {
            if let downloadTask = downloadManager.getDownloadTaskFor(transfer: transfer) {
                await downloadManager.removeDownloadTask(id: downloadTask.id)
                return
            }

            if let localURL = transfer.localArchiveURL,
               FileManager.default.fileExists(atPath: localURL.path()) {
                downloadedTransferURL = IdentifiableURL(url: localURL)
                return
            }

            Task {
                await notificationsHelper.requestPermissionIfNeeded()
            }

            try? await downloadManager.startDownload(transfer: transfer)
        }
    }
}
