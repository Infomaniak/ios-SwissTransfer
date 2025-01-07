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
import InfomaniakDI
import STCore

public actor DownloadManager {
    @LazyInjectService private var injection: SwissTransferInjection

    private let session: URLSession
    private let sessionDelegate: DownloadManagerSessionDelegate

    private var cancellables: Set<AnyCancellable> = []

    enum ErrorDomain: Error {
        case badResult
        case badURL
    }

    public init() {
        let sessionDelegate = DownloadManagerSessionDelegate()
        session = URLSession(configuration: .swissTransferBackground, delegate: sessionDelegate, delegateQueue: nil)
        self.sessionDelegate = sessionDelegate
    }

    private func getDownloadURLFor(file: FileUi, in transfer: TransferUi) async throws -> URL {
        guard let rawDownloadURL = try await injection.sharedApiUrlCreator.downloadFileUrl(
            transferUUID: transfer.uuid,
            fileUUID: file.uid
        ),
            let downloadURL = URL(string: rawDownloadURL) else {
            throw ErrorDomain.badURL
        }

        return downloadURL
    }

    private func getDownloadURLFor(transfer: TransferUi) async throws -> URL {
        if transfer.files.count == 1,
           let firstFile = transfer.files.first {
            return try await getDownloadURLFor(file: firstFile, in: transfer)
        }

        guard let rawDownloadURL = try await injection.sharedApiUrlCreator.downloadFilesUrl(transferUUID: transfer.uuid),
              let downloadURL = URL(string: rawDownloadURL) else {
            throw ErrorDomain.badURL
        }

        return downloadURL
    }

    public func download(file: FileUi,
                         in transfer: TransferUi,
                         progressCallback: @escaping @Sendable (Double) -> Void) async throws -> URL {
        let downloadURL = try await getDownloadURLFor(file: file, in: transfer)
        return try await download(
            url: downloadURL,
            transferUUID: transfer.uuid,
            fileUUID: file.uid,
            progressCallback: progressCallback
        )
    }

    public func download(transfer: TransferUi, progressCallback: @escaping @Sendable (Double) -> Void) async throws -> URL {
        let downloadURL = try await getDownloadURLFor(transfer: transfer)
        return try await download(
            url: downloadURL,
            transferUUID: transfer.uuid,
            fileUUID: nil,
            progressCallback: progressCallback
        )
    }

    private func download(
        url downloadURL: URL,
        transferUUID: String,
        fileUUID: String?,
        progressCallback: @escaping @Sendable (Double) -> Void
    ) async throws -> URL {
        let downloadRequest = try URLRequest(url: downloadURL, method: .get)
        let downloadTask = session.downloadTask(with: downloadRequest)
        downloadTask.taskDescription = "\(transferUUID)__\(fileUUID ?? ""))"

        downloadTask.progress
            .publisher(for: \.fractionCompleted)
            .receive(on: RunLoop.main)
            .sink { fractionCompleted in
                progressCallback(fractionCompleted)
            }
            .store(in: &cancellables)

        do {
            let downloadedFile = try await downloadFile(with: downloadTask)
            let destinationURL = try handleDownloadedFile(
                transferUUID: transferUUID,
                fileUUID: fileUUID,
                downloadedFile: downloadedFile
            )
            return destinationURL
        } catch DownloadManagerSessionDelegate.ErrorDomain.badResult(let url) {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
            throw ErrorDomain.badResult
        }
    }

    private func downloadFile(with downloadTask: URLSessionDownloadTask) async throws -> DownloadedFile {
        var cancellable: AnyCancellable?

        let downloadedFile: DownloadedFile = try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                cancellable = sessionDelegate.downloadCompletedSubject
                    .sink { downloadTaskCompletion in
                        guard downloadTaskCompletion.taskDescription == downloadTask.taskDescription else { return }

                        switch downloadTaskCompletion.result {
                        case .success(let downloadedFile):
                            continuation.resume(returning: downloadedFile)
                            cancellable?.cancel()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                            cancellable?.cancel()
                        }
                    }

                downloadTask.resume()
            }
        } onCancel: {
            downloadTask.cancel()
        }

        return downloadedFile
    }

    private nonisolated func handleDownloadedFile(
        transferUUID: String,
        fileUUID: String?,
        downloadedFile: DownloadedFile
    ) throws -> URL {
        defer {
            // Always try to cleanup result
            try? FileManager.default.removeItem(at: downloadedFile.url)
        }

        var destinationContainerURL = try URL.tmpDownloadsDirectory().appendingPathComponent("\(transferUUID)/")
        if let fileUUID {
            destinationContainerURL = destinationContainerURL.appendingPathComponent("\(fileUUID)")
        }

        let destinationURL = destinationContainerURL.appendingPathComponent(downloadedFile.filename)

        if !FileManager.default.fileExists(atPath: destinationContainerURL.path) {
            try FileManager.default.createDirectory(at: destinationContainerURL, withIntermediateDirectories: true)
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.moveItem(at: downloadedFile.url, to: destinationURL)

        return destinationURL
    }
}

final class DownloadManagerSessionDelegate: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate, @unchecked Sendable {
    let downloadCompletedSubject = PassthroughSubject<DownloadTaskCompletion, Never>()

    enum ErrorDomain: Error {
        case badResult(URL?)
    }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let taskDescription = downloadTask.taskDescription else { return }
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              httpResponse.statusCode <= 299 else {
            downloadCompletedSubject.send(DownloadTaskCompletion(
                taskDescription: taskDescription,
                result: .failure(ErrorDomain.badResult(location))
            ))
            return
        }

        do {
            let progressCacheURL = try URL.tmpInProgressDownloadsDirectory().appendingPathComponent(location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: progressCacheURL)

            downloadCompletedSubject.send(
                DownloadTaskCompletion(taskDescription: taskDescription,
                                       result: .success(DownloadedFile(
                                           suggestedFilename: httpResponse.suggestedFilename,
                                           url: progressCacheURL
                                       )))
            )
        } catch {
            downloadCompletedSubject.send(DownloadTaskCompletion(
                taskDescription: taskDescription,
                result: .failure(ErrorDomain.badResult(location))
            ))
        }
    }
}
