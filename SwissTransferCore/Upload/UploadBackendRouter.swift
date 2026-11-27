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

    public var isGuest: Bool {
        currentUser == nil
    }

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
        return TransferManagerWorkerV2(
            overallProgress: overallProgress,
            uploadSession: uploadSession,
            uploadBackendRouter: self,
            delegate: delegate
        )
    }

    public func getRestorableLocalUploadSession(uuid: String) async throws -> RootTransferRestorableState? {
        guard let uploadSessionRequest = try await sessionStore.get(uuid: uuid) else {
            return nil
        }

        return RootTransferRestorableState(uploadSessionRequest: uploadSessionRequest)
    }

    public func getLocalUploadSessionAuthorEmail(uuid: String) async throws -> String? {
        return try await sessionStore.get(uuid: uuid)?.authorEmail
    }

    public func createAndGetLocalUploadSessionUUID(request: UploadSessionRequest) async throws -> String {
        let localUUID = UUID().uuidString
        try await sessionStore.save(uuid: localUUID, session: request)

        return localUUID
    }

    public func createRemoteUploadSession(localSessionUUID: String) async throws -> SendableUploadSession {
        guard let localUploadSession = try await sessionStore.get(uuid: localSessionUUID) else {
            throw DomainError.localUploadSessionNotFound
        }

        let attestationTokenGenerator = UploadAttestationTokenGenerator()
        let transfer: STNTransferApi
        do {
            transfer = try await swissTransferManager.uploadV2Manager.prepareTransfer(
                request: localUploadSession,
                attestationTokenGenerator: attestationTokenGenerator
            )
        } catch {
            if let deviceCheckError = attestationTokenGenerator.lastError {
                throw deviceCheckError
            }
            throw error
        }

        let localFilePaths = Set(localUploadSession.filesMetadata.map { $0.localPath })

        try await sessionStore.remove(uuid: localSessionUUID)

        return try SendableUploadSession(
            transfer: transfer,
            authorEmail: localUploadSession.authorEmail,
            organizationAccountId: localUploadSession.organizationAccountId?.int64Value,
            localFilePaths: localFilePaths
        )
    }

    public func finishUploadSession(uuid: String, organizationAccountId: Int64? = nil) async throws -> String {
        return try await swissTransferManager.uploadV2Manager.finalizeTransferAndGetLinkUuid(
            transferId: uuid,
            organizationAccountId: KotlinLong(value: organizationAccountId)
        )
    }

    public func cancelUploadSession(uuid: String, organizationAccountId: Int64? = nil) async throws {
        _ = try await swissTransferManager.uploadV2Manager.cancelTransfer(
            transferId: uuid,
            organizationAccountId: KotlinLong(value: organizationAccountId),
            failed: false
        )
    }
}
