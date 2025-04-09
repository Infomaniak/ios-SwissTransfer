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
import SwissTransferCore

private struct UploadChunkInFile: Equatable, Sendable {
    let file: UploadFile
    let chunk: UploadChunk
    var task: Task<Void, Error>?

    public static func == (lhs: UploadChunkInFile, rhs: UploadChunkInFile) -> Bool {
        lhs.chunk == rhs.chunk
    }
}

private struct UploadChunk: Hashable, Equatable, Sendable {
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

    public static func == (lhs: UploadChunk, rhs: UploadChunk) -> Bool {
        lhs.fileURL == rhs.fileURL && lhs.index == rhs.index
    }
}

private struct UploadFile: Equatable, Sendable {
    let fileURL: URL
    let uploadChunks: [UploadChunk]
    let lastChunk: UploadChunk

    public static func == (lhs: UploadFile, rhs: UploadFile) -> Bool {
        lhs.fileURL == rhs.fileURL
    }
}

actor TransferManagerWorker {
    private static let maxParallelUploads = 4
    private let uploadURLSession: URLSession = .sharedSwissTransfer
    private let appStateObserver = AppStateObserver()

    private var uploadingFiles = [UploadFile]()
    private var uploadedFiles = [UploadFile]()

    private var doneUploading: Bool {
        uploadingFiles.count == uploadedFiles.count
    }

    private var uploadingChunks = [UploadChunkInFile]()
    private var uploadedChunks = [UploadChunkInFile]()

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

    init(overallProgress: Progress) {
        self.overallProgress = overallProgress
        appStateObserver.delegate = self
    }

    deinit {
        uploadingChunks.compactMap(\.task).forEach { $0.cancel() }
        uploadingChunks.removeAll()
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

        let totalChunks = uploadingFiles.reduce(0) { partialResult, uploadFile in
            partialResult + uploadFile.uploadChunks.count + 1
        }
        try await uploadAllFiles()
    }

    private func buildAllUploadTasks(forFileAtPath path: String, remoteUploadFileUUID: String, uploadUUID: String) async throws {
        guard let fileURL = URL(string: path) else {
            throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: path)
        }

        let rangeProvider = RangeProvider(fileURL: fileURL, config: rangeProviderConfig)

        let ranges = try rangeProvider.allRanges
        let indexedRanges = ranges.enumerated().map { ($0, $1) }
        var chunks = indexedRanges.map { index, range in
            let isLast = index == ranges.count - 1
            let uploadingChunk = UploadChunk(fileURL: fileURL,
                                             remoteUploadFileUUID: remoteUploadFileUUID,
                                             uploadUUID: uploadUUID,
                                             range: range,
                                             index: index,
                                             isLast: isLast)
            return uploadingChunk
        }

        guard let lastChunk = chunks.popLast() else {
            throw TransferSessionManager.ErrorDomain.invalidChunk
        }

        assert(lastChunk.isLast, "should be last")

        let uploadingFile = UploadFile(fileURL: fileURL, uploadChunks: chunks, lastChunk: lastChunk)
        uploadingFiles.append(uploadingFile)
    }

    private func uploadAllFiles() async throws {
        let expiringActivity = ExpiringActivity(id: "upload-\(UUID().uuidString)", delegate: self)
        expiringActivity.start()

        let allFiles = uploadingFiles.filter { !uploadedFiles.contains($0) }
        try await allFiles.asyncForEach { uploadFile in
            try await self.uploadAllChunks(forFile: uploadFile)
        }

        expiringActivity.endAll()
    }

    private func retryRemainingFiles() async throws {
        guard suspendedUploads, !doneUploading else {
            return
        }

        uploadingChunks.removeAll()
        suspendedUploads = false
        try await uploadAllFiles()
    }

    private func cancelAllTasks() {
        uploadingChunks.compactMap(\.task).forEach { $0.cancel() }
        uploadingChunks.removeAll()
        suspendedUploads = true
    }

    private func setStartUploading(chunk: UploadChunk, inFile file: UploadFile, task: Task<Void, Error>) {
        uploadingChunks.append(UploadChunkInFile(file: file, chunk: chunk, task: task))
    }

    private func setDoneUploading(chunk: UploadChunk, inFile file: UploadFile) {
        let chunkInFile = UploadChunkInFile(file: file, chunk: chunk)
        uploadedChunks.append(chunkInFile)
        uploadingChunks.removeAll { chunkInFile in
            chunkInFile.chunk == chunk
        }
    }

    private func uploadAllChunks(forFile uploadFile: UploadFile) async throws {
        try await uploadFile.uploadChunks.concurrentForEach(customConcurrency: Self.maxParallelUploads) { [weak self] chunk in
            guard let self else { return }
            let task = await self.getTask(withChunk: chunk)
            await self.setStartUploading(chunk: chunk, inFile: uploadFile, task: task)
            _ = try await task.value
            await self.setDoneUploading(chunk: chunk, inFile: uploadFile)
        }

        // last chunk to close session
        let lastChunk = uploadFile.lastChunk
        let task = getTask(withChunk: lastChunk)
        setStartUploading(chunk: lastChunk, inFile: uploadFile, task: task)
        _ = try await task.value
        setDoneUploading(chunk: lastChunk, inFile: uploadFile)
        uploadedFiles.append(uploadFile)
    }

    func uploadChunk(
        chunk: Data,
        index: Int,
        isLastChunk: Bool,
        remoteUploadFileUUID: String,
        uploadUUID: String
    ) async throws {
        @InjectService var injection: SwissTransferInjection
        guard let rawChunkURL = try injection.sharedApiUrlCreator.uploadChunkUrl(
            uploadUUID: uploadUUID,
            fileUUID: remoteUploadFileUUID,
            chunkIndex: Int32(index),
            isLastChunk: isLastChunk,
            isRetry: false
        ) else {
            throw TransferSessionManager.ErrorDomain.invalidUploadChunkURL
        }

        guard let chunkURL = URL(string: rawChunkURL) else {
            throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: rawChunkURL)
        }

        var uploadRequest = URLRequest(url: chunkURL)
        uploadRequest.httpMethod = Method.POST.rawValue

        let taskDelegate = UploadTaskDelegate(totalBytesExpectedToSend: chunk.count)
        overallProgress.addChild(taskDelegate.taskProgress, withPendingUnitCount: Int64(chunk.count))

        let (_, response) = try await uploadURLSession.upload(for: uploadRequest, from: chunk, delegate: taskDelegate)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransferSessionManager.ErrorDomain.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            throw TransferSessionManager.ErrorDomain.invalidChunkResponse
        }
    }

    private func getTask(withChunk chunk: UploadChunk) -> Task<Void, Error> {
        return Task { [weak self] in
            guard let self else { return }

            guard let chunkReader = ChunkReader(fileURL: chunk.fileURL) else {
                throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: chunk.fileURL.path)
            }

            guard let chunkData = try chunkReader.readChunk(range: chunk.range) else {
                throw TransferSessionManager.ErrorDomain.invalidChunk
            }

            try await self.uploadChunk(
                chunk: chunkData,
                index: chunk.index,
                isLastChunk: chunk.isLast,
                remoteUploadFileUUID: chunk.remoteUploadFileUUID,
                uploadUUID: chunk.uploadUUID
            )
        }
    }
}

extension TransferManagerWorker: @preconcurrency ExpiringActivityDelegate {
    func backgroundActivityExpiring() {
        cancelAllTasks()
    }
}

extension TransferManagerWorker: AppStateObserverDelegate {
    nonisolated func appDidBecomeActive() {
        Task {
            try await retryRemainingFiles()
        }
    }
}
