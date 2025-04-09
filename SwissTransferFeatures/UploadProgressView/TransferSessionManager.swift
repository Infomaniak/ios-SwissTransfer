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

final class UploadTaskDelegate: NSObject, URLSessionTaskDelegate {
    let taskProgress: Progress

    init(totalBytesExpectedToSend: Int) {
        taskProgress = Progress(totalUnitCount: Int64(totalBytesExpectedToSend))
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        taskProgress.completedUnitCount = totalBytesSent
    }
}

@MainActor
class TransferSessionManager: ObservableObject {
    @LazyInjectService private var injection: SwissTransferInjection

    @Published var completedBytes: Int64 = 0
    @Published var totalBytes: Int64 = 0

    private var cancellables: Set<AnyCancellable> = []
    private var transferManagerWorker: TransferManagerWorker?

    enum ErrorDomain: Error {
        case remoteContainerNotFound
        case invalidURL(rawURL: String)
        case invalidUploadChunkURL
        case invalidChunk
        case invalidRange
        case invalidResponse
        case invalidChunkResponse
    }

    func uploadFiles(for uploadSession: SendableUploadSession) async throws -> String {
        let expiringActivity = ExpiringActivity(id: "uploadSession-\(uploadSession.uuid)", delegate: self)
        expiringActivity.start()

        let filesSize = uploadSession.files.reduce(0) { $0 + $1.size }
        totalBytes = filesSize

        let overallProgress = Progress(totalUnitCount: filesSize)
        overallProgress
            .publisher(for: \.completedUnitCount)
            .receive(on: RunLoop.main)
            .sink { [weak self] completedUnitCount in
                self?.completedBytes = completedUnitCount
            }
            .store(in: &cancellables)

        let uploadManager = injection.uploadManager

        let remoteUploadFiles = uploadSession.files.compactMap { $0.remoteUploadFile }
        assert(remoteUploadFiles.count == uploadSession.files.count, "All files should have a remote upload file")

        let worker = TransferManagerWorker(overallProgress: overallProgress)
        transferManagerWorker = worker
        try await worker.uploadFiles(for: uploadSession, remoteUploadFiles: remoteUploadFiles)

        let transferUUID = try await uploadManager.finishUploadSession(uuid: uploadSession.uuid)

        expiringActivity.endAll()
        return transferUUID
    }
}

extension TransferSessionManager: ExpiringActivityDelegate {
    nonisolated func backgroundActivityExpiring() {
        @InjectService var notificationsHelper: NotificationsHelper
        notificationsHelper.sendUploadFailedExpiredNotificationForUploadSession()

        SentrySDK.capture(message: "Upload couldn't complete because the app went in the background")
    }
}
