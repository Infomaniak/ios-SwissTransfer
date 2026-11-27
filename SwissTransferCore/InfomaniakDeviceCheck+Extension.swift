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
    static func generateAttestationToken(targetUrl: URL) async throws -> String {
        do {
            #if DEBUG
            let attestationToken = try await InfomaniakDeviceCheck(environment: .preprod).generateAttestationFor(
                targetUrl: targetUrl,
                bundleId: Constants.bundleId,
                bypassValidation: true
            )
            Logger.general.warning("Since this is a debug build, attestation token validation is bypassed")
            #else
            let attestationToken = try await InfomaniakDeviceCheck(environment: .prod).generateAttestationFor(
                targetUrl: targetUrl,
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

/// Generates attestation tokens on demand for guest transfer creation.
///
/// Errors thrown back to Kotlin from this callback are not declared by `prepareTransfer` and would be fatal,
/// so on failure we return an empty token (making the backend reject the request) and keep the underlying error
/// to be rethrown by the caller.
final class UploadAttestationTokenGenerator: NSObject, AttestationTokenGenerator, @unchecked Sendable {
    private let lock = NSLock()
    private var _lastError: STDeviceCheckError?

    var lastError: STDeviceCheckError? {
        lock.withLock { _lastError }
    }

    func __generateAttestationToken(targetUrl: String) async throws -> String {
        do {
            guard let url = URL(string: targetUrl) else {
                throw URLError(.badURL)
            }
            return try await InfomaniakDeviceCheck.generateAttestationToken(targetUrl: url)
        } catch {
            Logger.general.error("Error while generating attestation token: \(error)")
            lock.withLock {
                _lastError = (error as? STDeviceCheckError) ?? STDeviceCheckError(underlyingError: error)
            }
            return ""
        }
    }
}
