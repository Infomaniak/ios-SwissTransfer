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
import InfomaniakCore
import InfomaniakDI
import OSLog
import RecaptchaEnterprise
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

class TransferSessionManager: ObservableObject {
    @LazyInjectService private var injection: SwissTransferInjection

    @Published var percentCompleted: Double = 0

    private let uploadUrlSession = URLSession.shared

    private var overhaulProgress: Progress?

    private var cancellables: Set<AnyCancellable> = []

    private static let rangeProviderConfig = RangeProvider.Config(
        chunkMinSize: 50 * 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 50 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )

    func startUpload(uploadSession: NewUploadSession) async {
        do {
            overhaulProgress = Progress(totalUnitCount: Int64(uploadSession.files.count))
            overhaulProgress?
                .publisher(for: \.fractionCompleted)
                .receive(on: RunLoop.main)
                .sink { [weak self] fractionCompleted in
                    self?.percentCompleted = fractionCompleted
                }
                .store(in: &cancellables)

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
                let localFile = uploadWithRemoteContainer.files[index]

                try await uploadFile(atPath: localFile.localPath, toRemoteFile: remoteUploadFile, uploadUUID: upload.uuid)
            }

            Logger.general.info("Found container: \(container.uuid)")

            try await uploadManager.finishUploadSession(uuid: upload.uuid)
        } catch let error as RecaptchaError {
            Logger.general.error("Recaptcha client error: \(error.errorMessage ?? "")")
        } catch {
            Logger.general.error("Error trying to start upload: \(error)")
        }
    }

    private func uploadFile(atPath: String, toRemoteFile: any RemoteUploadFile, uploadUUID: String) async throws {
        guard let fileURL = URL(string: atPath) else {
            fatalError("Wrong path")
        }

        let rangeProvider = RangeProvider(fileURL: fileURL, config: TransferSessionManager.rangeProviderConfig)

        let ranges = try rangeProvider.allRanges
        guard let chunkProvider = ChunkProvider(fileURL: fileURL, ranges: ranges) else {
            fatalError("Couldn't compute ranges")
        }

        let rangeCount = ranges.count
        let fileProgress = Progress(totalUnitCount: Int64(rangeCount))
        overhaulProgress?.addChild(fileProgress, withPendingUnitCount: 1)

        var index: Int32 = 0
        while let chunk = chunkProvider.next() {
            let chunkURL = try injection.sharedApiUrlCreator.uploadChunkUrl(
                uploadUUID: uploadUUID,
                fileUUID: toRemoteFile.uuid,
                chunkIndex: index,
                isLastChunk: index == rangeCount - 1
            )!

            var uploadRequest = URLRequest(url: URL(string: chunkURL)!)
            uploadRequest.httpMethod = "POST"

            let taskDelegate = UploadTaskDelegate(totalBytesExpectedToSend: chunk.count)
            fileProgress.addChild(taskDelegate.taskProgress, withPendingUnitCount: 1)
            try await uploadUrlSession.upload(for: uploadRequest, from: chunk, delegate: taskDelegate)

            index += 1
        }
    }
}
