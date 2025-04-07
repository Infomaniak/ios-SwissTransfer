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

struct TransferManagerWorker {
    private static let maxParallelUploads = 4
    private let uploadURLSession: URLSession = .sharedSwissTransfer

    private let rangeProviderConfig = RangeProvider.Config(
        chunkMinSize: 50 * 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 50 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )

    let overallProgress: Progress

    func uploadFiles(for uploadSession: SendableUploadSession, remoteUploadFiles: [SendableRemoteUploadFile]) async throws {
        try await remoteUploadFiles.enumerated()
            .map { (uploadSession.files[$0.offset], $0.element) }
            .asyncForEach { localFile, remoteUploadFile in
                try await uploadFile(
                    atPath: localFile.localPath,
                    remoteUploadFileUUID: remoteUploadFile.uuid,
                    uploadUUID: uploadSession.uuid
                )
            }
    }

    private func uploadFile(atPath: String, remoteUploadFileUUID: String, uploadUUID: String) async throws {
        guard let fileURL = URL(string: atPath),
              let chunkReader = ChunkReader(fileURL: fileURL) else {
            throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: atPath)
        }

        let rangeProvider = RangeProvider(fileURL: fileURL, config: rangeProviderConfig)

        var ranges = try rangeProvider.allRanges

        guard let lastRange = ranges.popLast() else {
            throw TransferSessionManager.ErrorDomain.invalidRange
        }

        try await ranges
            .enumerated()
            .map { ($0, $1) }
            .concurrentForEach(customConcurrency: 4) { index, range in
                guard let chunk = try chunkReader.readChunk(range: range) else {
                    throw TransferSessionManager.ErrorDomain.invalidChunk
                }

                try await uploadChunk(
                    chunk: chunk,
                    index: index,
                    isLastChunk: false,
                    remoteUploadFileUUID: remoteUploadFileUUID,
                    uploadUUID: uploadUUID
                )
            }

        guard let lastChunk = try chunkReader.readChunk(range: lastRange) else {
            throw TransferSessionManager.ErrorDomain.invalidChunk
        }

        try await uploadChunk(
            chunk: lastChunk,
            index: ranges.count,
            isLastChunk: true,
            remoteUploadFileUUID: remoteUploadFileUUID,
            uploadUUID: uploadUUID
        )
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
}
