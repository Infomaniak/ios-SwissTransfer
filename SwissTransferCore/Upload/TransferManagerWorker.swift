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

import Combine
import Foundation
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakDI
import OSLog
import Sentry
import STCore
import STNetwork

extension Result: Sendable where Success: Sendable, Failure: Sendable {}

private struct WorkerChunkInFile: Equatable, Sendable {
    let file: WorkerFile
    let chunk: WorkerChunk
    var task: Task<Void, Error>?

    static func == (lhs: WorkerChunkInFile, rhs: WorkerChunkInFile) -> Bool {
        lhs.chunk == rhs.chunk
    }
}

struct WorkerChunk: Equatable, Hashable, Sendable {
    let fileURL: URL
    let remoteUploadFileUUID: String
    let uploadUUID: String
    let range: DataRange
    let index: Int
    let isLast: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
        hasher.combine(index)
    }

    static func == (lhs: WorkerChunk, rhs: WorkerChunk) -> Bool {
        lhs.fileURL == rhs.fileURL && lhs.index == rhs.index
    }
}

private struct WorkerFile: Equatable, Sendable {
    let fileURL: URL
    let uploadChunks: [WorkerChunk]
    let lastChunk: WorkerChunk

    static func == (lhs: WorkerFile, rhs: WorkerFile) -> Bool {
        lhs.fileURL == rhs.fileURL
    }
}

public protocol TransferManagerWorkerDelegate: AnyObject, Sendable {
    @MainActor func uploadDidComplete(result: Result<String, NSError>)
}

public actor TransferManagerWorker {
    private static let maxParallelUploads = 4

    private let appStateObserver = AppStateObserver()
    private let uploadSession: SendableUploadSession
    private let uploadManager: UploadManager
    private weak var delegate: TransferManagerWorkerDelegate?

    private var uploadingFiles = [WorkerFile]()
    private var uploadedFiles = [WorkerFile]()

    private var doneUploading: Bool {
        uploadingFiles.count == uploadedFiles.count
    }

    private var uploadingChunks = [WorkerChunkInFile]()
    private var uploadedChunks = [WorkerChunkInFile]()

    private var chunkProgress = [WorkerChunk: UploadTaskProgressTracker]()

    private var suspendedUploads = false

    private let rangeProviderConfig = RangeProvider.Config(
        chunkMinSize: 50 * 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 50 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )

    let apiURLCreator: SharedApiUrlCreator
    let overallProgress: Progress
    let uploadURLSession: URLSession = .sharedSwissTransfer

    public init(overallProgress: Progress,
                uploadSession: SendableUploadSession,
                uploadManager: UploadManager,
                apiURLCreator: SharedApiUrlCreator,
                delegate: TransferManagerWorkerDelegate) {
        self.overallProgress = overallProgress
        self.uploadSession = uploadSession
        self.uploadManager = uploadManager
        self.apiURLCreator = apiURLCreator
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
        guard let fileURL = URL(string: path) else {
            throw ErrorDomain.invalidURL(rawURL: path)
        }

        let rangeProvider = RangeProvider(fileURL: fileURL, config: rangeProviderConfig)

        let ranges = try rangeProvider.allRanges
        let indexedRanges = ranges.enumerated().map { ($0, $1) }
        var chunks = indexedRanges.map { index, range in
            let isLast = index == ranges.count - 1
            let uploadingChunk = WorkerChunk(fileURL: fileURL,
                                             remoteUploadFileUUID: remoteUploadFileUUID,
                                             uploadUUID: uploadUUID,
                                             range: range,
                                             index: index,
                                             isLast: isLast)
            return uploadingChunk
        }

        guard let lastChunk = chunks.popLast() else {
            throw ErrorDomain.invalidChunk
        }

        assert(lastChunk.isLast, "expecting isLast flag to match the last in collection")

        let uploadingFile = WorkerFile(fileURL: fileURL, uploadChunks: chunks, lastChunk: lastChunk)
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
                try await self.uploadAllChunks(forFile: uploadFile)
            }

            let transferUUID = try await uploadManager.finishUploadSession(uuid: uploadSession.uuid)

            await delegate?.uploadDidComplete(result: .success(transferUUID))
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

    private func setStartUploading(chunk: WorkerChunk, inFile file: WorkerFile, task: Task<Void, Error>) {
        uploadingChunks.append(WorkerChunkInFile(file: file, chunk: chunk, task: task))
    }

    private func setDoneUploading(chunk: WorkerChunk, inFile file: WorkerFile) {
        let chunkInFile = WorkerChunkInFile(file: file, chunk: chunk)
        uploadedChunks.append(chunkInFile)
        uploadingChunks.removeAll { chunkInFile in
            chunkInFile.chunk == chunk
        }
    }

    private func uploadAllChunks(forFile uploadFile: WorkerFile) async throws {
        let uploadedChunksInFile = uploadedChunks.filter { chunkInFile in
            chunkInFile.file == uploadFile
        }.map(\.chunk)
        let chunksToUpload = uploadFile.uploadChunks.filter { !uploadedChunksInFile.contains($0) }

        try await chunksToUpload.concurrentForEach(customConcurrency: Self.maxParallelUploads) { [weak self] chunk in
            guard let self else { return }
            try await trackAndPerformUploadTask(withChunk: chunk, inFile: uploadFile)
        }

        let lastChunk = uploadFile.lastChunk
        try await trackAndPerformUploadTask(withChunk: lastChunk, inFile: uploadFile)

        uploadedFiles.append(uploadFile)
    }

    private func trackAndPerformUploadTask(withChunk chunk: WorkerChunk, inFile uploadFile: WorkerFile) async throws {
        let task = getTask(withChunk: chunk)
        setStartUploading(chunk: chunk, inFile: uploadFile, task: task)
        _ = try await task.value
        setDoneUploading(chunk: chunk, inFile: uploadFile)
    }

    private func getTask(withChunk chunk: WorkerChunk) -> Task<Void, Error> {
        let progressTracker = getProgressTracker(withChunk: chunk)
        return Task { [weak self] in
            guard let self else { return }

            guard let chunkReader = ChunkReader(fileURL: chunk.fileURL) else {
                throw ErrorDomain.invalidURL(rawURL: chunk.fileURL.path)
            }

            guard let chunkData = try chunkReader.readChunk(range: chunk.range) else {
                throw ErrorDomain.invalidChunk
            }

            try await uploadChunk(chunkData: chunkData,
                                  chunk: chunk,
                                  progressTracker: progressTracker)
        }
    }

    private func getProgressTracker(withChunk chunk: WorkerChunk) -> UploadTaskProgressTracker {
        guard let progress = chunkProgress[chunk] else {
            let chunkSize = chunk.range.count
            let progress = UploadTaskProgressTracker(totalBytesExpectedToSend: chunkSize)
            overallProgress.addChild(progress.taskProgress, withPendingUnitCount: Int64(chunkSize))
            chunkProgress[chunk] = progress
            return progress
        }

        return progress
    }
}

extension TransferManagerWorker: @preconcurrency ExpiringActivityDelegate {
    public func backgroundActivityExpiring() {
        suspendAllTasks()
    }
}

extension TransferManagerWorker: AppStateObserverDelegate {
    public nonisolated func appDidBecomeActive() {
        Task {
            try await retryRemainingFiles()
        }
    }
}
