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

import Foundation
import InfomaniakCore
import InfomaniakDI
import STCore
import STNetwork

extension TransferManagerWorkerV1 {
    func uploadChunk(chunkData: Data, chunk: WorkerChunk, progressTracker: UploadTaskProgressTracker) async throws {
        guard let rawChunkURL = try uploadBackendRouter.swissTransferManager.sharedApiUrlCreator.uploadChunkUrl(
            uploadUUID: chunk.uploadUUID,
            fileUUID: chunk.remoteUploadFileUUID,
            chunkIndex: Int32(chunk.index),
            isLastChunk: chunk.isLast,
            isRetry: false
        ) else {
            throw TransferManagerWorkerError.invalidUploadChunkURL
        }

        guard let chunkURL = URL(string: rawChunkURL) else {
            throw TransferManagerWorkerError.invalidURL(rawURL: rawChunkURL)
        }

        var uploadRequest = URLRequest(url: chunkURL)
        uploadRequest.httpMethod = Method.POST.rawValue

        let (_, response) = try await uploadURLSession.upload(for: uploadRequest, from: chunkData, delegate: progressTracker)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransferManagerWorkerError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            throw TransferManagerWorkerError.invalidChunkResponse
        }
    }
}
