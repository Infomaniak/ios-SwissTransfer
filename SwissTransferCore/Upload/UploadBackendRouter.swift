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

    private var localUploadSessions: [String: NewUploadSession] = [:]

    public init(currentUser: UserProfile?, swissTransferManager: SwissTransferInjection) {
        self.currentUser = currentUser
        self.swissTransferManager = swissTransferManager
    }

    public func getLocalUploadSession(uuid: String) async throws -> UploadSession? {
        if currentUser != nil {
            return nil
        } else {
            return try await swissTransferManager.uploadManager.getUploads().first { $0.uuid == uuid }
        }
    }

    public func createAndGetLocalUploadSessionUUID(newUploadSession: NewUploadSession) async throws -> String {
        if currentUser != nil {
            fatalError("TODO")
        } else {
            return try await swissTransferManager.uploadManager
                .createAndGetLocalUploadSessionUUID(newUploadSession: newUploadSession)
        }
    }

    public func createRemoteUploadSession(localSessionUUID: String) async throws -> SendableUploadSession {
        if let currentUser {
            fatalError("TODO")
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
            fatalError("TODO")
        } else {
            return try await swissTransferManager.uploadManager.finishUploadSession(uuid: uuid)
        }
    }
}
