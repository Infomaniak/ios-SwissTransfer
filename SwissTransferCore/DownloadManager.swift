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

@preconcurrency import Combine
import Foundation
import InfomaniakDI
import STCore

public struct DownloadTask: Equatable, Sendable, Identifiable {
    public let id: String
    public let state: DownloadTaskState

    public init(id: String, state: DownloadTaskState) {
        self.id = id
        self.state = state
    }
}

public enum DownloadTaskState: Equatable, Sendable {
    case running(current: Int64, total: Int64)
    case completed(URL)
    case error(Error)

    public static func == (lhs: DownloadTaskState, rhs: DownloadTaskState) -> Bool {
        switch (lhs, rhs) {
        case (.running(let lhsCurrent, let lhsTotal), .running(let rhsCurrent, let rhsTotal)):
            return lhsCurrent == rhsCurrent && lhsTotal == rhsTotal
        case (.completed(let lhs), .completed(let rhs)):
            return lhs == rhs
        case (.error(let lhs), .error(let rhs)):
            return lhs.localizedDescription == rhs.localizedDescription
        default: return false
        }
    }

    var isRunning: Bool {
        switch self {
        case .running:
            return true
        default:
            return false
        }
    }
}

@MainActor
public class DownloadManager: ObservableObject {
    @LazyInjectService private var injection: SwissTransferInjection
    @LazyInjectService private var notificationsHelper: NotificationsHelper

    private let session: URLSession

    private var cancellables: Set<AnyCancellable> = []

    @Published private var trackedDownloadTasks = [String: DownloadTask]()

    public var backgroundDownloadCompletionCallback: (() -> Void)? {
        didSet {
            guard let delegate = session.delegate as? DownloadManagerSessionDelegate else { return }
            delegate.backgroundDownloadCompletionCallback = backgroundDownloadCompletionCallback
        }
    }

    enum ErrorDomain: Error {
        case badURL
    }

    public init(sessionConfiguration: URLSessionConfiguration) {
        let sessionDelegate = DownloadManagerSessionDelegate()
        session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        sessionDelegate.downloadCompletedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadTaskCompletion in
                self?.handleDownloadTaskCompletion(downloadTaskCompletion)
            }
            .store(in: &cancellables)

        sessionDelegate.downloadRunningSubject
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] downloadTaskProgress in
                guard self?.trackedDownloadTasks[downloadTaskProgress.id]?.state.isRunning == true else { return }
                self?.updateDownloadTask(
                    id: downloadTaskProgress.id,
                    state: .running(current: downloadTaskProgress.current, total: downloadTaskProgress.total)
                )
            }
            .store(in: &cancellables)

        Task {
            for task in await session.allTasks {
                guard let taskId = task.taskDescription else { return }
                updateDownloadTask(id: taskId, state: .running(current: 0, total: 1))
            }
        }
    }

    public func getDownloadTaskFor(file: FileUi, in transfer: TransferUi) -> DownloadTask? {
        return getDownloadTaskFor(transfer: transfer, file: file)
    }

    public func getDownloadTaskFor(transfer: TransferUi) -> DownloadTask? {
        return getDownloadTaskFor(transfer: transfer, file: nil)
    }

    public func getDownloadTaskFor(transfer: TransferUi, file: FileUi?) -> DownloadTask? {
        let taskId = taskId(transferUUID: transfer.uuid, fileUUID: file?.uid)
        return trackedDownloadTasks[taskId]
    }

    private func updateDownloadTask(id: String, state: DownloadTaskState) {
        trackedDownloadTasks[id] = DownloadTask(id: id, state: state)
    }

    public func removeDownloadTask(id: String) async {
        if let task = await session.allTasks.first(where: { $0.taskDescription == id }) {
            task.cancel()
        }

        trackedDownloadTasks[id] = nil
    }

    public func startDownload(file: FileUi, in transfer: TransferUi) async throws {
        let downloadURL = try await getDownloadURLFor(file: file, in: transfer)
        let taskId = taskId(transferUUID: transfer.uuid, fileUUID: file.uid)
        try createDownloadTask(url: downloadURL, taskId: taskId, expectedSize: file.fileSize)
    }

    public func startDownload(transfer: TransferUi) async throws {
        let downloadURL = try await getDownloadURLFor(transfer: transfer)
        let taskId = taskId(transferUUID: transfer.uuid, fileUUID: nil)
        try createDownloadTask(url: downloadURL, taskId: taskId, expectedSize: transfer.sizeUploaded)
    }

    private func taskId(transferUUID: String, fileUUID: String?) -> String {
        "\(transferUUID)__\(fileUUID ?? "")"
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

    private func createDownloadTask(url downloadURL: URL, taskId: String, expectedSize: Int64) throws {
        let downloadRequest = try URLRequest(url: downloadURL, method: .get)
        let sessionDownloadTask = session.downloadTask(with: downloadRequest)
        sessionDownloadTask.taskDescription = taskId
        sessionDownloadTask.countOfBytesClientExpectsToReceive = expectedSize

        sessionDownloadTask.resume()

        updateDownloadTask(id: taskId, state: .running(current: 0, total: 1))
    }

    private func handleDownloadTaskCompletion(_ downloadTaskCompletion: DownloadTaskCompletion) {
        let transferUUIDAndFileUUID = downloadTaskCompletion.id.split(separator: "__")
        guard !transferUUIDAndFileUUID.isEmpty else { return }

        let transferUUID = String(transferUUIDAndFileUUID[0])
        let fileUUID = transferUUIDAndFileUUID.count > 1 ? String(transferUUIDAndFileUUID[1]) : nil

        switch downloadTaskCompletion.result {
        case .success(let downloadedFile):
            do {
                let resultURL = try handleDownloadedFile(
                    transferUUID: transferUUID,
                    fileUUID: fileUUID,
                    downloadedFile: downloadedFile
                )

                notificationsHelper.sendBackgroundDownloadSuccessNotificationIfNeeded(
                    transferUUID: transferUUID,
                    fileUUID: fileUUID,
                    filename: downloadedFile.filename
                )
                updateDownloadTask(
                    id: downloadTaskCompletion.id,
                    state: .completed(resultURL)
                )
            } catch {
                notificationsHelper.sendBackgroundDownloadErrorNotificationIfNeeded(
                    transferUUID: transferUUID,
                    fileUUID: fileUUID
                )
                updateDownloadTask(id: downloadTaskCompletion.id, state: .error(error))
            }
        case .failure(let error):
            notificationsHelper.sendBackgroundDownloadErrorNotificationIfNeeded(
                transferUUID: transferUUID,
                fileUUID: fileUUID
            )
            updateDownloadTask(id: downloadTaskCompletion.id, state: .error(error))
        }
    }

    private func handleDownloadedFile(transferUUID: String, fileUUID: String?, downloadedFile: DownloadedFile) throws -> URL {
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

final class DownloadManagerSessionDelegate: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate, Sendable {
    let downloadCompletedSubject = PassthroughSubject<DownloadTaskCompletion, Never>()
    let downloadRunningSubject = PassthroughSubject<DownloadTaskProgress, Never>()

    @MainActor var backgroundDownloadCompletionCallback: (() -> Void)?

    enum ErrorDomain: Error {
        case badResult(URL?)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let error,
              (error as NSError).code != NSURLErrorCancelled,
              let taskDescription = task.taskDescription else { return }

        downloadCompletedSubject.send(DownloadTaskCompletion(
            id: taskDescription,
            result: .failure(ErrorDomain.badResult(nil))
        ))
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let taskDescription = downloadTask.taskDescription, downloadTask.state == .running else { return }

        let total = totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown && totalBytesExpectedToWrite > 0 ?
            totalBytesExpectedToWrite : downloadTask.countOfBytesClientExpectsToReceive

        downloadRunningSubject.send(
            DownloadTaskProgress(
                id: taskDescription,
                current: totalBytesWritten,
                total: total
            )
        )
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let taskDescription = downloadTask.taskDescription else { return }
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              httpResponse.statusCode <= 299 else {
            downloadCompletedSubject.send(DownloadTaskCompletion(
                id: taskDescription,
                result: .failure(ErrorDomain.badResult(location))
            ))
            return
        }

        do {
            let progressCacheURL = try URL.tmpInProgressDownloadsDirectory().appendingPathComponent(location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: progressCacheURL)

            downloadCompletedSubject.send(
                DownloadTaskCompletion(id: taskDescription,
                                       result: .success(DownloadedFile(
                                           suggestedFilename: httpResponse.suggestedFilename,
                                           url: progressCacheURL
                                       )))
            )
        } catch {
            downloadCompletedSubject.send(DownloadTaskCompletion(
                id: taskDescription,
                result: .failure(ErrorDomain.badResult(location))
            ))
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Task { @MainActor in
            backgroundDownloadCompletionCallback?()
        }
    }
}
