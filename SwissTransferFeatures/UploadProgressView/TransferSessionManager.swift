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

import AsyncCollections
import Combine
import Foundation
import InfomaniakCore
import InfomaniakDI
import OSLog
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

    enum ErrorDomain: Error {
        case remoteContainerNotFound
        case invalidURL(rawURL: String)
        case invalidUploadChunkURL
        case invalidRangeCompute
        case invalidResponse
        case invalidChunkResponse
    }

    func startUpload(session newUploadSession: NewUploadSession) async throws -> String {
        let filesSize = newUploadSession.files.reduce(0) { $0 + $1.size }
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

        let uploadSession = try await uploadManager.createAndGetUpload(newUploadSession: newUploadSession)

        let uploadWithRemoteContainer = try await uploadManager.doInitUploadSession(
            uuid: uploadSession.uuid,
            recaptcha: "aabb"
        )

        guard let uploadWithRemoteContainer,
              let container = uploadWithRemoteContainer.remoteContainer else {
            throw ErrorDomain.remoteContainerNotFound
        }

        let remoteUploadFiles = uploadWithRemoteContainer.files.compactMap { $0.remoteUploadFile }
        assert(remoteUploadFiles.count == uploadWithRemoteContainer.files.count, "All files should have a remote upload file")

        let transferManagerWorker = TransferManagerWorker(overallProgress: overallProgress)

        try await remoteUploadFiles.enumerated()
            .map { (uploadWithRemoteContainer.files[$0.offset], $0.element) }
            .concurrentForEach { localFile, remoteUploadFile in
                try await transferManagerWorker.uploadFile(
                    atPath: localFile.localPath,
                    remoteUploadFileUUID: remoteUploadFile.uuid,
                    uploadUUID: uploadSession.uuid
                )
            }

        Logger.general.info("Found container: \(container.uuid)")

        let transferUUID = try await uploadManager.finishUploadSession(uuid: uploadSession.uuid)

        return transferUUID
    }
}

struct TransferManagerWorker {
    private static let maxParallelUploads = 4
    private let uploadURLSession = URLSession.shared
    private let parallelChunksSemaphore = AsyncSemaphore(value: maxParallelUploads)

    private let rangeProviderConfig = RangeProvider.Config(
        chunkMinSize: 50 * 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 50 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )

    let overallProgress: Progress

    func uploadFile(atPath: String, remoteUploadFileUUID: String, uploadUUID: String) async throws {
        guard let fileURL = URL(string: atPath) else {
            throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: atPath)
        }

        let rangeProvider = RangeProvider(fileURL: fileURL, config: rangeProviderConfig)

        let ranges = try rangeProvider.allRanges
        guard let chunkProvider = ChunkProvider(fileURL: fileURL, ranges: ranges) else {
            throw TransferSessionManager.ErrorDomain.invalidRangeCompute
        }

        var index: Int32 = 0
        try await withThrowingTaskGroup(of: Void.self) { group in
            while let chunk = chunkProvider.next() {
                try await parallelChunksSemaphore.wait()

                let isLastChunk = index == ranges.count - 1
                if !isLastChunk {
                    group.addTask {
                        try await uploadChunk(
                            chunk: chunk,
                            index: index,
                            isLastChunk: isLastChunk,
                            remoteUploadFileUUID: remoteUploadFileUUID,
                            uploadUUID: uploadUUID
                        )
                        parallelChunksSemaphore.signal()
                    }
                } else {
                    try await group.waitForAll()

                    try await uploadChunk(
                        chunk: chunk,
                        index: index,
                        isLastChunk: isLastChunk,
                        remoteUploadFileUUID: remoteUploadFileUUID,
                        uploadUUID: uploadUUID
                    )
                    parallelChunksSemaphore.signal()
                }

                index += 1
            }
        }
    }

    func uploadChunk(
        chunk: Data,
        index: Int32,
        isLastChunk: Bool,
        remoteUploadFileUUID: String,
        uploadUUID: String
    ) async throws {
        @InjectService var injection: SwissTransferInjection
        guard let rawChunkURL = try injection.sharedApiUrlCreator.uploadChunkUrl(
            uploadUUID: uploadUUID,
            fileUUID: remoteUploadFileUUID,
            chunkIndex: index,
            isLastChunk: isLastChunk
        ) else {
            throw TransferSessionManager.ErrorDomain.invalidUploadChunkURL
        }

        guard let chunkURL = URL(string: rawChunkURL) else {
            throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: rawChunkURL)
        }

        var uploadRequest = URLRequest(url: chunkURL)
        uploadRequest.httpMethod = "POST"

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
}
