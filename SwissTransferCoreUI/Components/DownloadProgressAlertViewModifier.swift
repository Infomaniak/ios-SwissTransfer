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

import DesignSystem
import InfomaniakCoreSwiftUI
import InfomaniakCoreUIResources
import STCore
import STResources
import SwiftUI
import SwissTransferCore

extension View {
    func downloadProgressAlertFor(
        transfer: TransferUi,
        file: FileUi? = nil,
        downloadCompletedCallback: ((URL) -> Void)? = nil
    ) -> some View {
        modifier(DownloadProgressAlertViewModifier(
            transfer: transfer,
            file: file,
            downloadCompletedCallback: downloadCompletedCallback
        ))
    }
}

struct DownloadProgressAlert: View {
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var currentProgress: Int64 = 0
    @State private var totalProgress: Int64 = 0

    let downloadTask: DownloadTask
    let downloadCompletedCallback: ((URL) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.mini) {
            Text(STResourcesStrings.Localizable.downloadInProgressDialogTitle)
                .font(.ST.headline)
            ProgressView(value: Double(currentProgress) / Double(totalProgress))
                .progressViewStyle(.linear)

            HStack(spacing: 2) {
                Text(currentProgress, format: .progressByteCount)
                Text(verbatim: "/")
                Text(totalProgress, format: .progressByteCount)
            }
            .opacity(currentProgress > 0 && totalProgress > 0 ? 1 : 0)
            .monospacedDigit()
            .font(.ST.callout)
            .foregroundStyle(.secondary)

            Button(CoreUILocalizable.buttonCancel) {
                Task {
                    await downloadManager.removeDownloadTask(id: downloadTask.id)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .buttonStyle(.ikBorderless(isInlined: true))
        }
        .task(id: downloadTask.state) {
            switch downloadTask.state {
            case .completed(let url):
                await downloadManager.removeDownloadTask(id: downloadTask.id)
                downloadCompletedCallback?(url)
            case .running(let current, let total):
                currentProgress = current
                totalProgress = total
            default:
                break
            }
        }
    }
}

struct DownloadProgressAlertViewModifier: ViewModifier {
    @EnvironmentObject private var downloadManager: DownloadManager

    let transfer: TransferUi
    let file: FileUi?
    let downloadCompletedCallback: ((URL) -> Void)?

    private var downloadTask: Binding<DownloadTask?> {
        Binding(
            get: {
                downloadManager.getDownloadTaskFor(transfer: transfer, file: file)
            }, set: { _ in
            }
        )
    }

    func body(content: Content) -> some View {
        content
            .customAlert(item: downloadTask) { downloadTask in
                DownloadProgressAlert(downloadTask: downloadTask, downloadCompletedCallback: downloadCompletedCallback)
            }
    }
}

#Preview {
    DownloadProgressAlert(
        downloadTask: DownloadTask(id: "", state: .completed(URL(string: "/")!)),
        downloadCompletedCallback: nil
    )
    .environmentObject(DownloadManager())
}
