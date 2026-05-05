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
@preconcurrency import STCore

public final class UploadBackendRouter: Sendable {
    let currentUser: UserProfile?
    let swissTransferManager: SwissTransferInjection
    let sessionStore: LocalUploadSessionStore

    enum DomainError: Error {
        case localUploadSessionNotFound
    }

    public init(currentUser: UserProfile?, swissTransferManager: SwissTransferInjection) {
        self.currentUser = currentUser
        self.swissTransferManager = swissTransferManager
        sessionStore = LocalUploadSessionStore(uploadV2Manager: swissTransferManager.uploadV2Manager)
    }

    public func instantiateTransferManagerWorker(overallProgress: Progress,
                                                 uploadSession: SendableUploadSession,
                                                 delegate: TransferManagerWorkerDelegate) -> TransferManagerWorker {
        if currentUser != nil {
            return TransferManagerWorkerV2(
                overallProgress: overallProgress,
                uploadSession: uploadSession,
                uploadBackendRouter: self,
                delegate: delegate
            )
        } else {
            return TransferManagerWorkerV1(
                overallProgress: overallProgress,
                uploadSession: uploadSession,
                uploadBackendRouter: self,
                delegate: delegate
            )
        }
    }

    public func getRestorableLocalUploadSession(uuid: String) async throws -> RootTransferRestorableState? {
        if currentUser != nil {
            guard let uploadSessionRequest = try await sessionStore.get(uuid: uuid) else {
                return nil
            }

            return RootTransferRestorableState(uploadSessionRequest: uploadSessionRequest)
        } else {
            guard let uploadSession = try await swissTransferManager.uploadManager.getUploads().first(where: { $0.uuid == uuid })
            else {
                return nil
            }

            return RootTransferRestorableState(uploadSession: uploadSession)
        }
    }

    public func createAndGetLocalUploadSessionUUID(newUploadSession: NewUploadSession,
                                                   title: String? = nil) async throws -> String {
        if currentUser != nil {
            var filesMetadata: [FileToUploadMetadata] = []
            var sizeOfUpload: Int64 = 0
            for file in newUploadSession.files {
                filesMetadata.append(FileToUploadMetadata(
                    name: file.name,
                    size: file.size,
                    mimeType: file.mimeType,
                    localPath: file.localPath
                ))
                sizeOfUpload += file.size
            }

            let request = UploadSessionRequest(
                validityPeriod: newUploadSession.duration,
                authorEmail: newUploadSession.authorEmail,
                password: newUploadSession.password,
                title: title,
                message: newUploadSession.message,
                sizeOfUpload: sizeOfUpload,
                downloadCountLimit: newUploadSession.numberOfDownload,
                filesCount: Int32(newUploadSession.files.count),
                languageCode: newUploadSession.language,
                filesMetadata: filesMetadata,
                recipientsEmails: newUploadSession.recipientsEmails
            )

            let localUUID = UUID().uuidString
            try await sessionStore.save(uuid: localUUID, session: request)

            return localUUID
        } else {
            return try await swissTransferManager.uploadManager
                .createAndGetLocalUploadSessionUUID(newUploadSession: newUploadSession)
        }
    }

    public func createRemoteUploadSession(localSessionUUID: String) async throws -> SendableUploadSession {
        if currentUser != nil {
            guard let localUploadSession = try await sessionStore.get(uuid: localSessionUUID) else {
                throw DomainError.localUploadSessionNotFound
            }

            do {
                let transfer = try await swissTransferManager.uploadV2Manager.prepareTransfer(request: localUploadSession)
                let localFilePaths = Set(localUploadSession.filesMetadata.map { $0.localPath })

                try await sessionStore.remove(uuid: localSessionUUID)

                return try SendableUploadSession(transfer: transfer, localFilePaths: localFilePaths)
            } catch {
                throw error
            }
        } else {
            return try await swissTransferManager.uploadManager.createRemoteUploadSession(
                localSessionUUID: localSessionUUID,
                uploadTokensManager: swissTransferManager.uploadTokensManager,
                sharedApiUrlCreator: swissTransferManager.sharedApiUrlCreator
            )
        }
    }

    public func finishUploadSession(uuid: String) async throws -> String {
        if currentUser != nil {
            return try await swissTransferManager.uploadV2Manager.finalizeTransferAndGetLinkUuid(transferId: uuid)
        } else {
            return try await swissTransferManager.uploadManager.finishUploadSession(uuid: uuid)
        }
    }

    public func cancelUploadSession(uuid: String) async throws {
        if currentUser != nil {
            _ = try await swissTransferManager.uploadV2Manager.cancelTransfer(transferId: uuid, failed: false)
        } else {
            try await swissTransferManager.uploadManager.cancelUploadSession(uuid: uuid)
        }
    }
}
