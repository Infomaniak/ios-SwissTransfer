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

import Foundation
import InfomaniakCore
import InfomaniakDI
import OSLog
import RecaptchaEnterprise
import STCore
import STNetwork
import SwissTransferCore

class TransferSessionManager: ObservableObject {
    @LazyInjectService private var injection: SwissTransferInjection

    let transferManager: TransferManager
    let uploadUrlSession = URLSession.shared

    let rangeProviderConfig = RangeProvider.Config(
        chunkMinSize: 50 * 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 50 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )

    init(transferManager: TransferManager) {
        self.transferManager = transferManager
    }

    func startUpload(uploadSession: NewUploadSession) async {
        do {
            let uploadManager = injection.uploadManager

            _ = try await uploadManager.createUpload(newUploadSession: uploadSession)

            guard let upload = try await uploadManager.getLastUpload() else {
                Logger.general.error("No remote container found")
                return
            }

            try await uploadManager.doInitUploadSession(uuid: upload.uuid, recaptcha: "aabb")

            guard let uploadWithRemoteContainer = try await uploadManager.getLastUpload(),
                  let container = uploadWithRemoteContainer.remoteContainer else {
                Logger.general.error("No remote container found")
                return
            }

            let remoteUploadFiles = uploadWithRemoteContainer.files.compactMap { $0.remoteUploadFile }
            assert(remoteUploadFiles.count == uploadWithRemoteContainer.files.count, "Cast should always success")

            for (index, remoteUploadFile) in remoteUploadFiles.enumerated() {
                guard let localFile = uploadWithRemoteContainer.files[index] as? UploadFile else {
                    fatalError("Cast should always success")
                }

                try await uploadFile(atPath: localFile.url, toRemoteFile: remoteUploadFile, uploadUUID: upload.uuid)
            }

            Logger.general.info("Found container: \(container.uuid)")

            try await uploadManager.finishUploadSession(uuid: upload.uuid)
        } catch let error as RecaptchaError {
            Logger.general.error("Recaptcha client error: \(error.errorMessage ?? "")")
        } catch {
            Logger.general.error("Error trying to start upload: \(error)")
        }
    }

    private func uploadFile(atPath: URL, toRemoteFile: any RemoteUploadFile, uploadUUID: String) async throws {
        let rangeProvider = RangeProvider(fileURL: atPath, config: rangeProviderConfig)

        let ranges = try rangeProvider.allRanges
        guard let chunkProvider = ChunkProvider(fileURL: atPath, ranges: ranges) else {
            fatalError("Couldn't compute ranges")
        }

        var index: Int32 = 0
        while let chunk = chunkProvider.next() {
            let chunkURL = try injection.sharedApiUrlCreator.uploadChunkUrl(
                uploadUUID: uploadUUID,
                fileUUID: toRemoteFile.uuid,
                chunkIndex: index,
                isLastChunk: index == ranges.count - 1
            )!

            var uploadRequest = URLRequest(url: URL(string: chunkURL)!)
            uploadRequest.httpMethod = "POST"

            try await uploadUrlSession.upload(for: uploadRequest, from: chunk)

            index += 1
        }
    }
}
