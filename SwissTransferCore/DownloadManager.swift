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
import InfomaniakCoreCommonUI
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

public final class MultiDownloadTask: Equatable, Sendable, Identifiable, ObservableObject {
    public static func == (lhs: MultiDownloadTask, rhs: MultiDownloadTask) -> Bool {
        lhs.id == rhs.id &&
            lhs.trackedDownloadTasks == rhs.trackedDownloadTasks
    }

    public let id: String
    @Published public var trackedDownloadTasks = [String: DownloadTask]()

    public var size: Int64

    public init?(id: String, size: Int64) {
        self.id = id
        self.size = size
    }

    public var state: DownloadTaskState {
        guard !trackedDownloadTasks.isEmpty else {
            return .running(current: 0, total: size)
        }

        guard !trackedDownloadTasks.values.filter(\.state.isRunning).isEmpty else {
            var urls = [URL]()
            var errors = [Error]()
            for task in trackedDownloadTasks.values {
                if case .completed(let url) = task.state {
                    urls += url
                } else if case .error(let error) = task.state {
                    errors.append(error)
                }
            }

            if urls.isEmpty, let error = errors.first {
                return .error(error)
            }
            return .completed(urls)
        }

        var percentage: Int64 = 0
        for task in trackedDownloadTasks.values {
            if case .running(let current, let total) = task.state {
                percentage += current * 100 / total
            } else {
                percentage += 100
            }
        }
        percentage /= Int64(trackedDownloadTasks.count)

        return .running(current: size * percentage / 100, total: size)
    }
}

public enum DownloadTaskState: Equatable, Sendable {
    case running(current: Int64, total: Int64)
    case completed([URL])
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

    @Published public var trackedMultiDownloadTask: MultiDownloadTask?
    @Published public var localDownloadOnly = false

    public var localURLs = [URL]()

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
                guard self?.trackedMultiDownloadTask?.trackedDownloadTasks[downloadTaskProgress.id]?.state.isRunning == true
                else { return }
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

    public func getMultiDownloadTaskFor(transfer: TransferUi, files: [FileUi]) -> MultiDownloadTask? {
        let multiTaskId = multiTaskId(transferUUID: transfer.uuid, filesUUID: files.map(\.uid))

        guard trackedMultiDownloadTask?.id == multiTaskId else { return nil }
        return trackedMultiDownloadTask
    }

    private func updateDownloadTask(id: String, state: DownloadTaskState) {
        trackedMultiDownloadTask?.trackedDownloadTasks[id] = DownloadTask(id: id, state: state)
    }

    public func removeMultiDownloadTask() async {
        guard let trackedMultiDownloadTask else { return }
        self.trackedMultiDownloadTask = nil
        for task in trackedMultiDownloadTask.trackedDownloadTasks.values {
            await removeDownloadTask(id: task.id)
        }
    }

    private func removeDownloadTask(id: String) async {
        if let task = await session.allTasks.first(where: { $0.taskDescription == id }) {
            task.cancel()
        }

        trackedMultiDownloadTask?.trackedDownloadTasks[id] = nil
    }

    public func startOrCancelDownload(transfer: TransferUi, files: [FileUi], matomoCategory: MatomoCategory) {
        @InjectService var matomo: MatomoUtils
        let matomoName: MatomoName = files.count == 1 ? .consultOneFile : .downloadTransfer
        matomo.track(eventWithCategory: matomoCategory, name: matomoName)

        Task {
            if getMultiDownloadTaskFor(transfer: transfer, files: files) != nil {
                await removeMultiDownloadTask()
                return
            }

            if files.isEmpty {
                // Download Transfer
                await startOrCancelTransferDownload(transfer: transfer)
            } else {
                await startOrCancelFilesDownload(transfer: transfer, files: files)
            }
        }
    }

    private func startOrCancelTransferDownload(transfer: TransferUi) async {
        if let url = transfer.localArchiveURL,
           FileManager.default.fileExists(atPath: url.path()) {
            localURLs = [url]
            localDownloadOnly = true
            return
        }

        Task {
            await notificationsHelper.requestPermissionIfNeeded()
        }

        try? await startDownload(transfer: transfer)
    }

    private func startOrCancelFilesDownload(transfer: TransferUi, files: [FileUi]) async {
        let localFiles: [String: URL] = Dictionary(
            uniqueKeysWithValues: files.compactMap { file in
                guard let url = file.localURLFor(transfer: transfer),
                      FileManager.default.fileExists(atPath: url.path()) else { return nil }
                return (file.uid, url)
            }
        )
        localURLs = Array(localFiles.values)

        if localFiles.count == files.count {
            localDownloadOnly = true
            return
        }

        Task {
            await notificationsHelper.requestPermissionIfNeeded()
        }

        let filesToDownload = files.filter { localFiles[$0.uid] == nil }

        try? await startDownload(files: filesToDownload, in: transfer)
    }

    private func startDownload(files: [FileUi], in transfer: TransferUi) async throws {
        let multiTaskId = multiTaskId(transferUUID: transfer.uuid, filesUUID: files.map(\.uid))
        let multiDownloadTask = MultiDownloadTask(
            id: multiTaskId,
            size: files.filesSize()
        )
        trackedMultiDownloadTask = multiDownloadTask

        for file in files {
            try? await startDownload(file: file, in: transfer)
        }
    }

    private func startDownload(file: FileUi, in transfer: TransferUi) async throws {
        let downloadURL = try await getDownloadURLFor(file: file, in: transfer)
        let taskId = taskId(transferUUID: transfer.uuid, fileUUID: file.uid)
        try createDownloadTask(url: downloadURL, taskId: taskId, expectedSize: file.fileSize)
    }

    private func startDownload(transfer: TransferUi) async throws {
        let downloadURL = try await getDownloadURLFor(transfer: transfer)
        let taskId = taskId(transferUUID: transfer.uuid, fileUUID: nil)
        try createDownloadTask(url: downloadURL, taskId: taskId, expectedSize: transfer.sizeUploaded)
    }

    private func taskId(transferUUID: String, fileUUID: String?) -> String {
        "\(transferUUID)__\(fileUUID ?? "")"
    }

    private func multiTaskId(transferUUID: String, filesUUID: [String]) -> String {
        return "\(transferUUID)__\(filesUUID.sorted().joined(separator: "-"))"
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
                    state: .completed([resultURL])
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
