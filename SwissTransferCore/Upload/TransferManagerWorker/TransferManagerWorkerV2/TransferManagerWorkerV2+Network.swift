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
    func uploadChunk(chunkData: Data, chunk: WorkerChunkV2,
                     progressTracker: UploadTaskProgressTracker) async throws -> STNChunkEtag {
        let chunkIndex = Int32(chunk.index)
        let rawChunkURL = try await uploadBackendRouter.swissTransferManager.uploadV2Manager.getUploadFileChunkUrl(
            transferId: chunk.uploadUUID,
            fileId: chunk.remoteUploadFileUUID,
            chunkIndex: chunkIndex
        )

        guard let chunkURL = URL(string: rawChunkURL) else {
            throw TransferManagerWorkerError.invalidURL(rawURL: rawChunkURL)
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

    func uploadFile(forFile uploadFile: WorkerFileV2) async throws {
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
                                                              fromFile: uploadFile.fileURL,
                                                              delegate: progressTracker)
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
        uploadedFiles.append(uploadFile)
    }
}
