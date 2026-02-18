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
import Foundation
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakDI
import OSLog
import Sentry
import STCore
import STNetwork
import SwissTransferCore
import UIKit

@MainActor
final class TransferSessionManager: ObservableObject {
    @LazyInjectService private var thumbnailProvider: ThumbnailProvidable

    @Published var fractionCompleted: Double = 0
    @Published var totalBytes: Int64 = 0
    @Published var transferResult: Result<String, NSError>?

    private var cancellables: Set<AnyCancellable> = []
    private var transferManagerWorker: TransferManagerWorker?
    private var thumbnailTask: Task<[(String, URL)], Never>?
    private let displayScale = UIScreen.main.scale

    func uploadFiles(
        for uploadSession: SendableUploadSession,
        with uploadManager: UploadManager,
        apiURLCreator: SharedApiUrlCreator
    ) async throws {
        startThumbnailGeneration(uploadSession: uploadSession)

        let filesSize = uploadSession.files.reduce(0) { $0 + $1.size }
        totalBytes = filesSize

        let overallProgress = Progress(totalUnitCount: filesSize)
        overallProgress
            .publisher(for: \.fractionCompleted)
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] fractionCompleted in
                self?.fractionCompleted = fractionCompleted
            }
            .store(in: &cancellables)

        let remoteUploadFiles = uploadSession.files.compactMap { $0.remoteUploadFile }
        assert(remoteUploadFiles.count == uploadSession.files.count, "All files should have a remote upload file")

        let worker = TransferManagerWorker(
            overallProgress: overallProgress,
            uploadSession: uploadSession,
            uploadManager: uploadManager,
            apiURLCreator: apiURLCreator,
            delegate: self
        )
        transferManagerWorker = worker

        try await worker.uploadFiles(for: uploadSession, remoteUploadFiles: remoteUploadFiles)
    }

    func startThumbnailGeneration(uploadSession: SendableUploadSession) {
        thumbnailTask = Task {
            await thumbnailProvider.generateTemporaryThumbnailsFor(
                uploadSession: uploadSession,
                scale: displayScale
            )
        }
    }

    func finishThumbnailGeneration(transferUUID: String) async {
        guard let thumbnailTask else {
            return
        }

        let uuidsWithThumbnail = await thumbnailTask.value
        thumbnailProvider.moveTemporaryThumbnails(
            uuidsWithThumbnail: uuidsWithThumbnail,
            transferUUID: transferUUID
        )
    }
}

extension TransferSessionManager: UploadCancellable {
    func cancelUploads() async {
        await transferManagerWorker?.suspendAllTasks()
        transferManagerWorker = nil
    }
}

extension TransferSessionManager: TransferManagerWorkerDelegate {
    @MainActor func uploadDidComplete(result: Result<String, NSError>) {
        Task {
            if case .success(let transferUUID) = result {
                await finishThumbnailGeneration(transferUUID: transferUUID)
            }

            transferResult = result
        }
    }
}
