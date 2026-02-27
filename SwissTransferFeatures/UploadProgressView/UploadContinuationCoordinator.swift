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

import BackgroundTasks
@preconcurrency import Combine
import Foundation
import InfomaniakDI
import NotificationCenter
import OSLog
import STCore
import STResources
import SwissTransferCore

struct UploadContinuationCoordinator {
    private enum DomainError: Error {
        case expiredTask
    }

    private let taskIdentifier: String

    init() {
        taskIdentifier = "\(Constants.bundleId).background-upload.\(UUID().uuidString)"
    }

    func startUploadWithBackgroundContinuation(
        with transferSessionManager: TransferSessionManager,
        uploadSession: SendableUploadSession,
        uploadBackendRouter: UploadBackendRouter
    ) async throws {
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            guard #available(iOS 26.0, *) else {
                fallbackUploadInForeground(
                    with: transferSessionManager,
                    uploadSession: uploadSession,
                    uploadBackendRouter: uploadBackendRouter,
                    continuation: continuation
                )
                return
            }

            let request = BGContinuedProcessingTaskRequest(
                identifier: taskIdentifier,
                title: STResourcesStrings.Localizable.uploadProgressIndication,
                subtitle: STResourcesStrings.Localizable.notificationProgressSubtitle(0.formatted(.defaultPercent))
            )

            BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
                guard let task = task as? BGContinuedProcessingTask else {
                    fallbackUploadInForeground(
                        with: transferSessionManager,
                        uploadSession: uploadSession,
                        uploadBackendRouter: uploadBackendRouter,
                        continuation: continuation
                    )
                    return
                }

                var continuation: CheckedContinuation<Void, any Error>? = continuation

                task.expirationHandler = {
                    Task { @MainActor in
                        await transferSessionManager.cancelUploads()
                        continuation?.resume(throwing: DomainError.expiredTask)
                        continuation = nil
                        task.setTaskCompleted(success: false)
                    }
                }

                Task {
                    let cancellable: AnyCancellable
                    do {
                        task.progress.totalUnitCount = 100
                        cancellable = await transferSessionManager.$fractionCompleted.sink { progress in
                            task.progress.completedUnitCount = Int64(progress * 100)
                            task.updateTitle(
                                STResourcesStrings.Localizable.uploadProgressIndication,
                                subtitle: STResourcesStrings.Localizable
                                    .notificationProgressSubtitle(progress.formatted(.defaultPercent))
                            )
                        }
                        try await transferSessionManager.uploadFiles(for: uploadSession, with: uploadBackendRouter)
                        continuation?.resume()
                        continuation = nil
                        task.setTaskCompleted(success: true)
                    } catch {
                        continuation?.resume(throwing: error)
                        continuation = nil
                        task.setTaskCompleted(success: false)
                    }
                    cancellable.cancel()
                }
            }

            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                Logger.general.info("Failed to submit request: \(error)")
                fallbackUploadInForeground(
                    with: transferSessionManager,
                    uploadSession: uploadSession,
                    uploadBackendRouter: uploadBackendRouter,
                    continuation: continuation
                )
            }
        }
    }

    private func fallbackUploadInForeground(
        with transferSessionManager: TransferSessionManager,
        uploadSession: SendableUploadSession,
        uploadBackendRouter: UploadBackendRouter,
        continuation: CheckedContinuation<Void, any Error>
    ) {
        Task {
            let observationToken: NSObjectProtocol = NotificationCenter.default.addObserver(
                forName: UIScene.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { _ in
                @InjectService var notificationsHelper: NotificationsHelper
                notificationsHelper.sendBackgroundUploadNotificationForUploadSession()
            }

            do {
                try await transferSessionManager.uploadFiles(for: uploadSession, with: uploadBackendRouter)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
            NotificationCenter.default.removeObserver(observationToken)
        }
    }
}
