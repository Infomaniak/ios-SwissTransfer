/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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
import QuickLook
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct DownloadResult: Identifiable {
    let id = UUID().uuidString
    let urls: [URL]
}

struct FileGridView: View {
    @EnvironmentObject private var downloadManager: DownloadManager
    @LazyInjectService private var multipleSelectionManager: MultipleSelectionManager

    let files: [FileUi]
    let transfer: TransferUi?
    let matomoCategory: MatomoCategory

    @State private var shareResult: DownloadResult?
    @State private var previewResult: URL?

    var body: some View {
        FileGridLayoutView {
            FileGridCellsView(files: files, transfer: transfer, matomoCategory: matomoCategory)
        }
        .downloadProgressAlert { urls in
            manageDownloadedURLs(urls: urls)
        }
        .onChange(of: downloadManager.localDownloadOnly) { _ in
            guard downloadManager.localDownloadOnly else { return }
            manageDownloadedURLs(urls: [])
            downloadManager.localDownloadOnly = false
        }
        .sheet(item: $shareResult) { downloadResult in
            ActivityView(sharedFileURLs: downloadResult.urls)
                .onAppear {
                    multipleSelectionManager.disable()
                }
        }
        .quickLookPreview($previewResult)
    }

    private func manageDownloadedURLs(urls: [URL]) {
        var allURLs = urls
        allURLs.append(contentsOf: downloadManager.localURLs)

        if allURLs.count == 1,
           let url = allURLs.first,
           QLPreviewController.canPreview(url as QLPreviewItem) {
            previewResult = url
        } else {
            shareResult = DownloadResult(urls: allURLs)
        }
    }
}

#Preview {
    FileGridView(files: [PreviewHelper.sampleFile], transfer: PreviewHelper.sampleTransfer, matomoCategory: .sentTransfer)
}
