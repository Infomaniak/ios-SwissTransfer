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

@MainActor
final class TransferSessionManager: ObservableObject {
    @LazyInjectService private var injection: SwissTransferInjection

    @Published var completedBytes: Int64 = 0
    @Published var totalBytes: Int64 = 0
    @Published var transferResult: Result<String, NSError>?

    private var cancellables: Set<AnyCancellable> = []
    private var transferManagerWorker: TransferManagerWorker?

    public func uploadFiles(
        for uploadSession: SendableUploadSession
    ) async throws {
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

        let remoteUploadFiles = uploadSession.files.compactMap { $0.remoteUploadFile }
        assert(remoteUploadFiles.count == uploadSession.files.count, "All files should have a remote upload file")

        let worker = TransferManagerWorker(overallProgress: overallProgress, uploadSession: uploadSession, delegate: self)
        transferManagerWorker = worker

        try await worker.uploadFiles(for: uploadSession, remoteUploadFiles: remoteUploadFiles)
    }
}

extension TransferSessionManager: UploadCancellable {
    public func cancelUploads() async {
        print("cancelAllUploads")
        await transferManagerWorker?.suspendAllTasks()
        transferManagerWorker = nil
    }
}

extension TransferSessionManager: TransferManagerWorkerDelegate {
    @MainActor func uploadDidComplete(result: Result<String, NSError>) {
        self.transferResult = result
    }
}
