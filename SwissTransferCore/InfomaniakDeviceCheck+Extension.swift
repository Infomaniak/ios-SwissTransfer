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
import OSLog
import STCore

public struct STDeviceCheckError: Error, Sendable {
    public let underlyingError: Error
}

public extension InfomaniakDeviceCheck {
    static func generateAttestationTokenForUploadContainer() async throws -> String {
        do {
            @InjectService var injection: SwissTransferInjection
            #if DEBUG
            let attestationToken = try await InfomaniakDeviceCheck(environment: .prod).generateAttestationFor(
                targetUrl: URL(string: injection.sharedApiUrlCreator.createUploadContainerUrl)!,
                bundleId: Constants.bundleId,
                bypassValidation: true
            )
            Logger.general.warning("Since this is a debug build, attestation token validation is bypassed")
            #else
            let attestationToken = try await InfomaniakDeviceCheck(environment: .prod).generateAttestationFor(
                targetUrl: URL(string: injection.sharedApiUrlCreator.createUploadContainerUrl)!,
                bundleId: Constants.bundleId,
                bypassValidation: false
            )
            #endif
            return attestationToken
        } catch {
            throw STDeviceCheckError(underlyingError: error)
        }
    }
}
