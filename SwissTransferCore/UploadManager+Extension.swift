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

import Foundation
import InfomaniakDeviceCheck
import InfomaniakDI
import STCore

public extension UploadManager {
    enum DomainError: Error {
        case containerNotFound
        case deviceCheckFailed
        case dailyQuotaExceeded
    }

    func createAndGetSendableUploadSession(newUploadSession: NewUploadSession) async throws -> SendableUploadSession {
        do {
            let uploadSession = try await createAndGetUpload(newUploadSession: newUploadSession)
            return SendableUploadSession(uploadSession: uploadSession)
        } catch let error as NSError
            where error.kotlinException is STNContainerErrorsException {
            throw DomainError.dailyQuotaExceeded
        }
    }

    func initSendableUploadSession(uuid: String, isRetrying: Bool) async throws -> SendableUploadSession {
        guard let uploadSession = try await doInitUploadSession(uuid: uuid,
                                                                attestationHeaderName: InfomaniakDeviceCheck.tokenHeaderField,
                                                                isRetrying: isRetrying) else {
            throw DomainError.containerNotFound
        }
        return SendableUploadSession(uploadSession: uploadSession)
    }

    func createRemoteUploadSession(localSessionUUID: String) async throws -> SendableUploadSession {
        do {
            let uploadSessionWithRemoteContainer = try await initSendableUploadSession(uuid: localSessionUUID, isRetrying: false)
            return uploadSessionWithRemoteContainer
        } catch let error as NSError
            where error.kotlinException is STNAttestationTokenException.InvalidAttestationTokenException {
            guard let attestationToken = await InfomaniakDeviceCheck.generateAttestationTokenForUploadContainer() else {
                throw DomainError.deviceCheckFailed
            }

            @InjectService var injection: SwissTransferInjection
            try await injection.uploadTokensManager.setAttestationToken(attestationToken: attestationToken)

            let uploadSessionWithRemoteContainer = try await initSendableUploadSession(uuid: localSessionUUID, isRetrying: true)
            return uploadSessionWithRemoteContainer
        }
    }
}
