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

import Combine
import SwiftUI
import SwissTransferCore

struct DownloadProgressView: View {
    @EnvironmentObject private var downloadManager: DownloadManager

    @State private var cancellable: AnyCancellable?
    @State private var progress: Double = 0

    let downloadTask: DownloadTask
    let downloadCompleteCallback: ((URL) -> Void)?

    var body: some View {
        ProgressView(value: progress)
            .progressViewStyle(.circularDeterminate)
            .task(id: downloadTask.state) {
                switch downloadTask.state {
                case .running(let task):
                    cancellable = task.progress
                        .publisher(for: \.fractionCompleted)
                        .receive(on: RunLoop.main)
                        .sink { value in
                            progress = value
                        }
                case .completed(let url):
                    cancellable = nil
                    downloadCompleteCallback?(url)
                    downloadManager.removeDownloadTask(id: downloadTask.id)
                default:
                    cancellable = nil
                }
            }
    }
}
