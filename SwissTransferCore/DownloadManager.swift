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

public actor DownloadManager: NSObject {
    @LazyInjectService private var injection: SwissTransferInjection

    private let session: URLSession = .shared

    private var progressCallbacks = [String: Progress]()
    private var cancellables: Set<AnyCancellable> = []

    enum ErrorDomain: Error {
        case badURL
        case badResult
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
        let progress = Progress(totalUnitCount: 1)
        progress
            .publisher(for: \.fractionCompleted)
            .receive(on: RunLoop.main)
            .sink { fractionCompleted in
                progressCallback(fractionCompleted)
            }
            .store(in: &cancellables)
        addProgress(for: downloadURL.absoluteString, progress: progress)

        let (downloadedFileURL, response) = try await session.download(for: downloadRequest, delegate: self)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode <= 299 else {
            try? FileManager.default.removeItem(at: downloadedFileURL)
            throw ErrorDomain.badResult
        }

        var destinationContainerURL = try URL.tmpDownloadsDirectory().appendingPathComponent("\(transferUUID)/")
        if let fileUUID {
            destinationContainerURL = destinationContainerURL.appendingPathComponent("\(fileUUID)")
        }

        let destinationURL: URL
        if let filename = httpResponse.suggestedFilename {
            destinationURL = destinationContainerURL.appendingPathComponent(filename)
        } else {
            destinationURL = destinationContainerURL.appendingPathComponent(downloadedFileURL.lastPathComponent)
        }

        if !FileManager.default.fileExists(atPath: destinationContainerURL.path) {
            try FileManager.default.createDirectory(at: destinationContainerURL, withIntermediateDirectories: true)
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.moveItem(at: downloadedFileURL, to: destinationURL)

        return destinationURL
    }

    func addProgress(for requestURL: String, progress: Progress) {
        progressCallbacks[requestURL] = progress
    }
}

extension DownloadManager: URLSessionTaskDelegate {
    public nonisolated func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        guard let requestURL = task.originalRequest?.url?.absoluteString else { return }

        Task {
            await progressCallbacks[requestURL]?.addChild(task.progress, withPendingUnitCount: 1)
        }
    }
}
