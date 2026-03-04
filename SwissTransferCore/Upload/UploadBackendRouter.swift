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

    enum DomainError: Error {
        case localUploadSessionNotFound
    }

    private var localUploadSessions: [String: String] = [:]

    public init(currentUser: UserProfile?, swissTransferManager: SwissTransferInjection) {
        self.currentUser = currentUser
        self.swissTransferManager = swissTransferManager
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

    public func getLocalUploadSession(uuid: String) async throws -> UploadSession? {
        if currentUser != nil {
            return nil
        } else {
            return try await swissTransferManager.uploadManager.getUploads().first { $0.uuid == uuid }
        }
    }

    public func createAndGetLocalUploadSessionUUID(newUploadSession: NewUploadSession) async throws -> String {
        if let currentUser {
            var filesMetadata: [FileToUploadMetadata] = []
            var sizeOfUpload: Int64 = 0
            var localFilePaths = Set<String>()
            for file in newUploadSession.files {
                filesMetadata.append(FileToUploadMetadata(
                    name: file.name,
                    size: file.size,
                    mimeType: file.mimeType,
                    localPath: file.localPath
                ))
                sizeOfUpload += file.size
                localFilePaths.insert(file.localPath)
            }

            let request = UploadSessionRequest(
                validityPeriod: newUploadSession.duration,
                authorEmail: currentUser.email,
                password: newUploadSession.password,
                title: nil,
                message: newUploadSession.message,
                sizeOfUpload: sizeOfUpload,
                downloadCountLimit: newUploadSession.numberOfDownload,
                filesCount: Int32(newUploadSession.files.count),
                languageCode: newUploadSession.language,
                filesMetadata: filesMetadata,
                recipientsEmails: newUploadSession.recipientsEmails
            )

            let localUUID = UUID().uuidString
            let encodedSession = try await swissTransferManager.uploadV2Manager.encodeSessionRequest(request: request)
            localUploadSessions[localUUID] = encodedSession

            return localUUID
        } else {
            return try await swissTransferManager.uploadManager
                .createAndGetLocalUploadSessionUUID(newUploadSession: newUploadSession)
        }
    }

    public func createRemoteUploadSession(localSessionUUID: String) async throws -> SendableUploadSession {
        if currentUser != nil {
            guard let localRawUploadSession = localUploadSessions[localSessionUUID],
                  let localUploadSession = try? await swissTransferManager.uploadV2Manager
                  .decodeSessionRequest(encodedString: localRawUploadSession) else {
                throw DomainError.localUploadSessionNotFound
            }

            let transfer = try await swissTransferManager.uploadV2Manager.prepareTransfer(request: localUploadSession)

            let localFilePaths = Set(localUploadSession.filesMetadata.map { $0.localPath })
            localUploadSessions[localSessionUUID] = nil

            return try SendableUploadSession(transfer: transfer, localFilePaths: localFilePaths)
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
            let uuid = try await swissTransferManager.uploadV2Manager.finalizeTransferAndGetLinkUuid(transferId: uuid)
            return uuid
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
