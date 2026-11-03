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

import Foundation
import InfomaniakCore
import InfomaniakDI
import STCore
import STNetwork

extension TransferManagerWorkerV2 {
    func uploadChunk(
        chunkData: Data,
        chunk: WorkerChunkV2,
        presignedURL: String,
        progressTracker: UploadTaskProgressTracker
    ) async throws -> STNChunkEtag {
        try Task.checkCancellation()

        let chunkIndex = Int32(chunk.index)

        guard let chunkURL = URL(string: presignedURL) else {
            throw TransferManagerWorkerError.invalidURL(rawURL: presignedURL)
        }

        var uploadRequest = URLRequest(url: chunkURL)
        uploadRequest.httpMethod = Method.PUT.rawValue

        let (_, response) = try await uploadURLSession.upload(for: uploadRequest, from: chunkData, delegate: progressTracker)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransferManagerWorkerError.invalidResponse
        }

        guard httpResponse.statusCode < 400,
              let etag = httpResponse.allHeaderFields["Etag"] as? String else {
            throw TransferManagerWorkerError.invalidChunkResponse
        }

        return STNChunkEtag(etag: etag, chunkIndex: chunkIndex)
    }

    func uploadFiles(forFiles uploadFiles: [WorkerFileV2], runID: UUID) async throws {
        for batch in uploadFiles.batched(ofCount: 10) {
            try checkUploadRunIsActive(runID)

            let requests = batch.map { STNBatchPresignedUrlRequest(file: $0.remoteUploadFileUUID, chunk: nil) }
            let responses = try await uploadBackendRouter.swissTransferManager.uploadV2Manager.getBatchPresignedUploadUrls(
                transferId: uploadSession.uuid,
                uploadUrlRequests: requests
            )

            try checkUploadRunIsActive(runID)

            let urlByFile = Dictionary(uniqueKeysWithValues: responses.map { ($0.file, $0.url) })

            for uploadFile in batch {
                let rangeProvider = RangeProvider(fileURL: uploadFile.fileURL, config: rangeProviderConfig)
                let fileSize = try rangeProvider.fileSize
                let progressTracker = getProgressTracker(forFile: uploadFile, fileSize: Int(fileSize))

                guard let rawURL = urlByFile[uploadFile.remoteUploadFileUUID] else {
                    throw TransferManagerWorkerError.missingPresignedURL(fileId: uploadFile.remoteUploadFileUUID)
                }

                guard let fileUrl = URL(string: rawURL) else { throw TransferManagerWorkerError.invalidURL(rawURL: rawURL) }

                var uploadRequest = URLRequest(url: fileUrl)
                uploadRequest.httpMethod = Method.PUT.rawValue

                let (_, response) = try await uploadURLSession.upload(for: uploadRequest,
                                                                      fromFile: uploadFile.fileURL,
                                                                      delegate: progressTracker)

                try checkUploadRunIsActive(runID)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw TransferManagerWorkerError.invalidResponse
                }

                guard httpResponse.statusCode < 400 else {
                    throw TransferManagerWorkerError.invalidFileResponse
                }

                try await uploadBackendRouter.swissTransferManager.uploadV2Manager.finalizeDirectFileUploaded(
                    transferId: uploadSession.uuid,
                    fileId: uploadFile.remoteUploadFileUUID
                )

                try checkUploadRunIsActive(runID)
                uploadedFiles.append(uploadFile)
            }
        }
    }
}
