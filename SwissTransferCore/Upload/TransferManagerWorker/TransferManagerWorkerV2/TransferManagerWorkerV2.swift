/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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

public actor TransferManagerWorkerV2: TransferManagerWorker {
    private static let maxParallelUploads = 4

    private let appStateObserver = AppStateObserver()
    private let uploadSession: SendableUploadSession
    let uploadBackendRouter: UploadBackendRouter
    private weak var delegate: TransferManagerWorkerDelegate?

    private var uploadingFiles = [WorkerFileV2]()
    private var uploadedFiles = [WorkerFileV2]()

    private var doneUploading: Bool {
        uploadingFiles.count == uploadedFiles.count
    }

    private var uploadingChunks = [WorkerChunkInFileV2]()
    private var uploadedChunks = [WorkerChunkInFileV2]()

    private var chunkProgress = [WorkerChunkV2: UploadTaskProgressTracker]()

    private var suspendedUploads = false

    private let rangeProviderConfig = RangeProvider.Config(
        chunkMinSize: 50 * 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 50 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )

    let overallProgress: Progress
    let uploadURLSession: URLSession = .sharedSwissTransfer

    public init(overallProgress: Progress,
                uploadSession: SendableUploadSession,
                uploadBackendRouter: UploadBackendRouter,
                delegate: TransferManagerWorkerDelegate) {
        self.overallProgress = overallProgress
        self.uploadSession = uploadSession
        self.uploadBackendRouter = uploadBackendRouter
        self.delegate = delegate
        appStateObserver.delegate = self
    }

    deinit {
        uploadingChunks.compactMap(\.task).forEach { $0.cancel() }
    }

    public func uploadFiles(for uploadSession: SendableUploadSession,
                            remoteUploadFiles: [SendableRemoteUploadFile]) async throws {
        try await remoteUploadFiles.enumerated()
            .map { (uploadSession.files[$0.offset], $0.element) }
            .asyncForEach { localFile, remoteUploadFile in
                try await self.buildAllUploadTasks(forFileAtPath: localFile.localPath,
                                                   remoteUploadFileUUID: remoteUploadFile.uuid,
                                                   uploadUUID: uploadSession.uuid)
            }

        await uploadAllFiles()
    }

    public func suspendAllTasks() {
        uploadingChunks.compactMap(\.task).forEach { $0.cancel() }
        uploadingChunks.removeAll()
        suspendedUploads = true
    }

    private func buildAllUploadTasks(forFileAtPath path: String, remoteUploadFileUUID: String, uploadUUID: String) async throws {
        let fileURL = URL(filePath: path)
        let rangeProvider = RangeProvider(fileURL: fileURL, config: rangeProviderConfig)

        let ranges = try rangeProvider.allRanges
        let indexedRanges = ranges.enumerated().map { ($0, $1) }
        let chunks = indexedRanges.map { index, range in
            let uploadingChunk = WorkerChunkV2(fileURL: fileURL,
                                               remoteUploadFileUUID: remoteUploadFileUUID,
                                               uploadUUID: uploadUUID,
                                               range: range,
                                               index: index + 1)
            return uploadingChunk
        }

        let uploadChunks = chunks.count > 1 ? chunks : []
        let uploadingFile = WorkerFileV2(fileURL: fileURL,
                                         uploadUUID: uploadUUID,
                                         remoteUploadFileUUID: remoteUploadFileUUID,
                                         uploadChunks: uploadChunks)
        uploadingFiles.append(uploadingFile)
    }

    private func uploadAllFiles() async {
        do {
            let expiringActivity = ExpiringActivity(id: "upload-\(UUID().uuidString)", delegate: self)
            expiringActivity.start()
            defer {
                expiringActivity.endAll()
            }

            let allFiles = uploadingFiles.filter { !uploadedFiles.contains($0) }

            try await allFiles.asyncForEach { uploadFile in
                if uploadFile.uploadChunks.isEmpty {
                    try await self.uploadFile(forFile: uploadFile)
                } else {
                    try await self.uploadAllChunks(forFile: uploadFile)
                }
            }

            let linkId = try await uploadBackendRouter.finishUploadSession(uuid: uploadSession.uuid)

            await delegate?.uploadDidComplete(result: .success(TransferCompletedResult(
                transferUUID: uploadSession.uuid,
                transferLinkId: linkId
            )))
        } catch let error as URLError where error.code == .cancelled {
            // silent catching, uploads are suspending
        } catch {
            await delegate?.uploadDidComplete(result: .failure(error as NSError))
        }
    }

    private func retryRemainingFiles() async throws {
        guard suspendedUploads, !doneUploading else {
            return
        }

        uploadingChunks.removeAll()
        suspendedUploads = false
        await uploadAllFiles()
    }

    private func setStartUploading(chunk: WorkerChunkV2, inFile file: WorkerFileV2, task: Task<STNChunkEtag, Error>) {
        uploadingChunks.append(WorkerChunkInFileV2(file: file, chunk: chunk, task: task))
    }

    private func setDoneUploading(chunk: WorkerChunkV2, inFile file: WorkerFileV2) {
        let chunkInFile = WorkerChunkInFileV2(file: file, chunk: chunk)
        uploadedChunks.append(chunkInFile)
        uploadingChunks.removeAll { chunkInFile in
            chunkInFile.chunk == chunk
        }
    }

    private func uploadAllChunks(forFile uploadFile: WorkerFileV2) async throws {
        let uploadedChunksInFile = uploadedChunks.filter { chunkInFile in
            chunkInFile.file == uploadFile
        }.map(\.chunk)
        let chunksToUpload = uploadFile.uploadChunks.filter { !uploadedChunksInFile.contains($0) }

        let chunkEtags = try await chunksToUpload.concurrentMap(customConcurrency: Self.maxParallelUploads) { [weak self] chunk in
            guard let self else {
                throw TransferManagerWorkerError.invalidChunk
            }
            let chunkEtag = try await trackAndPerformUploadTask(withChunk: chunk, inFile: uploadFile)
            return chunkEtag
        }

        try await uploadBackendRouter.swissTransferManager.uploadV2Manager.finalizeFileUploadedInChunks(
            transferId: uploadSession.uuid,
            fileId: uploadFile.remoteUploadFileUUID,
            etags: chunkEtags.sorted { $0.chunkIndex < $1.chunkIndex }
        )
        uploadedFiles.append(uploadFile)
    }

    private func trackAndPerformUploadTask(withChunk chunk: WorkerChunkV2,
                                           inFile uploadFile: WorkerFileV2) async throws -> STNChunkEtag {
        let task = getTask(withChunk: chunk)
        setStartUploading(chunk: chunk, inFile: uploadFile, task: task)
        let chunkEtag = try await task.value
        setDoneUploading(chunk: chunk, inFile: uploadFile)

        return chunkEtag
    }

    private func getTask(withChunk chunk: WorkerChunkV2) -> Task<STNChunkEtag, Error> {
        let progressTracker = getProgressTracker(withChunk: chunk)
        return Task { [weak self] in
            guard let self else {
                throw TransferManagerWorkerError.invalidChunk
            }

            guard let chunkReader = ChunkReader(fileURL: chunk.fileURL) else {
                throw TransferManagerWorkerError.invalidURL(rawURL: chunk.fileURL.path)
            }

            guard let chunkData = try chunkReader.readChunk(range: chunk.range) else {
                throw TransferManagerWorkerError.invalidChunk
            }

            return try await uploadChunk(chunkData: chunkData,
                                         chunk: chunk,
                                         progressTracker: progressTracker)
        }
    }

    private func getProgressTracker(withChunk chunk: WorkerChunkV2) -> UploadTaskProgressTracker {
        guard let progress = chunkProgress[chunk] else {
            let chunkSize = chunk.range.count
            let progress = UploadTaskProgressTracker(totalBytesExpectedToSend: chunkSize)
            overallProgress.addChild(progress.taskProgress, withPendingUnitCount: Int64(chunkSize))
            chunkProgress[chunk] = progress
            return progress
        }

        return progress
    }

    private func uploadFile(forFile uploadFile: WorkerFileV2) async throws {
        let rangeProvider = RangeProvider(fileURL: uploadFile.fileURL, config: rangeProviderConfig)
        let fileSize = try rangeProvider.fileSize
        let progressTracker = UploadTaskProgressTracker(totalBytesExpectedToSend: Int(fileSize))
        overallProgress.addChild(progressTracker.taskProgress, withPendingUnitCount: Int64(fileSize))

        let rawFileUrl = try await uploadBackendRouter.swissTransferManager.uploadV2Manager.getUploadFileUrl(
            transferId: uploadFile.uploadUUID, fileId: uploadFile.remoteUploadFileUUID
        )

        guard let fileUrl = URL(string: rawFileUrl) else {
            throw TransferManagerWorkerError.invalidURL(rawURL: rawFileUrl)
        }

        var uploadRequest = URLRequest(url: fileUrl)
        uploadRequest.httpMethod = Method.PUT.rawValue

        let (_, response) = try await uploadURLSession.upload(for: uploadRequest,
                                                              from: Data(contentsOf: uploadFile.fileURL),
                                                              delegate: progressTracker)
        guard response is HTTPURLResponse else {
            throw TransferManagerWorkerError.invalidResponse
        }

        try await uploadBackendRouter.swissTransferManager.uploadV2Manager.finalizeDirectFileUploaded(
            transferId: uploadSession.uuid,
            fileId: uploadFile.remoteUploadFileUUID
        )
        uploadedFiles.append(uploadFile)
    }
}

extension TransferManagerWorkerV2: @preconcurrency ExpiringActivityDelegate {
    public func backgroundActivityExpiring() {
        suspendAllTasks()
    }
}

extension TransferManagerWorkerV2: AppStateObserverDelegate {
    public nonisolated func appDidBecomeActive() {
        Task {
            try await retryRemainingFiles()
        }
    }
}
