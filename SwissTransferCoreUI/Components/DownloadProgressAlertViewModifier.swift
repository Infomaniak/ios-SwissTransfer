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

public extension View {
    func downloadProgressAlert(downloadCompletedCallback: (([URL]) -> Void)? = nil) -> some View {
        modifier(DownloadProgressAlertViewModifier(downloadCompletedCallback: downloadCompletedCallback))
    }
}

enum DownloadProgressAlertState {
    case idle
    case running(currentProgress: Int64, totalProgress: Int64)
    case error(Error)
}

struct DownloadProgressAlert: View {
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var state: DownloadProgressAlertState = .idle

    @ObservedObject var multiDownloadTask: MultiDownloadTask
    let downloadCompletedCallback: (([URL]) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.mini) {
            switch state {
            case .idle:
                Text(STResourcesStrings.Localizable.downloadInProgressDialogTitle)
                    .font(.ST.headline)
            case let .running(currentProgress, totalProgress):
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
            case .error:
                Text(STResourcesStrings.Localizable.notificationDownloadErrorNotificationTitle)
                    .font(.ST.headline)

                Text(STResourcesStrings.Localizable.notificationDownloadErrorDescription)
                    .font(.ST.callout)
                    .foregroundStyle(.secondary)
            }

            Button(CoreUILocalizable.buttonCancel) {
                Task {
                    await downloadManager.removeMultiDownloadTask()
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .buttonStyle(.ikBorderless(isInlined: true))
        }
        .task(id: multiDownloadTask.state) {
            switch multiDownloadTask.state {
            case let .completed(urls):
                downloadCompletedCallback?(urls)
                await downloadManager.removeMultiDownloadTask()
            case let .running(current, total):
                state = .running(currentProgress: current, totalProgress: total)
            case let .error(error):
                state = .error(error)
            }
        }
    }
}

struct DownloadProgressAlertViewModifier: ViewModifier {
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var multiDownloadTask: MultiDownloadTask?
    let downloadCompletedCallback: (([URL]) -> Void)?

    func body(content: Content) -> some View {
        content
            .stCustomAlert(item: $multiDownloadTask) { multiDownloadTask in
                DownloadProgressAlert(multiDownloadTask: multiDownloadTask, downloadCompletedCallback: downloadCompletedCallback)
            }
            .onChange(of: downloadManager.trackedMultiDownloadTask) { _ in
                multiDownloadTask = downloadManager.trackedMultiDownloadTask
            }
    }
}

#Preview {
    DownloadProgressAlert(
        multiDownloadTask: MultiDownloadTask(id: "", size: 0)!,
        downloadCompletedCallback: nil
    )
    .environmentObject(DownloadManager(sessionConfiguration: .swissTransfer))
}
