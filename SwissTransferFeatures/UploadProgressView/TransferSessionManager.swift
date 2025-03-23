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
import InfomaniakConcurrency
import InfomaniakCore
import InfomaniakDI
import OSLog
import Sentry
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
        case invalidChunk
        case invalidRange
        case invalidResponse
        case invalidChunkResponse
    }

    func uploadFiles(for uploadSession: SendableUploadSession) async throws -> String {
        let expiringActivity = ExpiringActivity(id: "uploadSession-\(uploadSession.uuid)", delegate: self)
        expiringActivity.start()

        let filesSize = uploadSession.files.reduce(0) { $0 + $1.size }
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

        let remoteUploadFiles = uploadSession.files.compactMap { $0.remoteUploadFile }
        assert(remoteUploadFiles.count == uploadSession.files.count, "All files should have a remote upload file")

        let transferManagerWorker = TransferManagerWorker(overallProgress: overallProgress)

        try await remoteUploadFiles.enumerated()
            .map { (uploadSession.files[$0.offset], $0.element) }
            .asyncForEach { localFile, remoteUploadFile in
                try await transferManagerWorker.uploadFile(
                    atPath: localFile.localPath,
                    host: uploadSession.uploadHost!,
                    containerUUID: uploadSession.remoteContainerUUID!,
                    remoteUploadFileUUID: remoteUploadFile.uuid
                )
            }

        let transferUUID = try await uploadManager.finishUploadSession(uuid: uploadSession.uuid)

        expiringActivity.endAll()
        return transferUUID
    }
}

extension TransferSessionManager: ExpiringActivityDelegate {
    nonisolated func backgroundActivityExpiring() {
        @InjectService var notificationsHelper: NotificationsHelper
        notificationsHelper.sendUploadFailedExpiredNotificationForUploadSession()

        SentrySDK.capture(message: "Upload couldn't complete because the app went in the background")
    }
}

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

    func uploadFile(atPath: String, host: String, containerUUID: String, remoteUploadFileUUID: String) async throws {
        guard let fileURL = URL(string: atPath) else {
            throw TransferSessionManager.ErrorDomain.invalidURL(rawURL: atPath)
        }

        let fileSize = fileURL.size()
        let taskDelegate = UploadTaskDelegate(totalBytesExpectedToSend: fileSize)
        overallProgress.addChild(taskDelegate.taskProgress, withPendingUnitCount: Int64(fileSize))

        let proxURL =
            URL(
                string: "http://proxyman.debug:8080/upload?containerUUID=\(containerUUID)&uploadFileUUID=\(remoteUploadFileUUID)"
            )!
        var uploadRequest = URLRequest(url: proxURL)
        uploadRequest.httpMethod = "POST"
        uploadRequest.setValue(host, forHTTPHeaderField: "x-upload-host")
        let (_, response) = try await uploadURLSession.upload(for: uploadRequest, fromFile: fileURL, delegate: taskDelegate)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransferSessionManager.ErrorDomain.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            throw TransferSessionManager.ErrorDomain.invalidChunkResponse
        }
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
