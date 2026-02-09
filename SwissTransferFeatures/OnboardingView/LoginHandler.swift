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

import AuthenticationServices
import InfomaniakCore
import InfomaniakCoreUIResources
import InfomaniakDeviceCheck
import InfomaniakDI
import InfomaniakLogin
import InterAppLogin
import STCore
import SwiftUI
import SwissTransferCore

@MainActor
public final class LoginHandler: InfomaniakLoginDelegate, ObservableObject {
    @LazyInjectService private var loginService: InfomaniakLoginable
    @LazyInjectService private var tokenService: InfomaniakNetworkLoginable
    @LazyInjectService private var accountManager: SwissTransferCore.AccountManager

    @Published var isLoading = false
    @Published var error: ErrorDomain?

    enum ErrorDomain: Error, LocalizedError, Equatable {
        case loginFailed(error: Error)
        case genericError

        var errorDescription: String? {
            switch self {
            case .loginFailed(let error):
                return error.localizedDescription
            case .genericError:
                return CoreUILocalizable.anErrorHasOccurred
            }
        }

        static func == (lhs: LoginHandler.ErrorDomain, rhs: LoginHandler.ErrorDomain) -> Bool {
            switch (lhs, rhs) {
            case (.loginFailed, .loginFailed):
                return true
            case (.genericError, .genericError):
                return true
            default:
                return false
            }
        }
    }

    public func didCompleteLoginWith(code: String, verifier: String) {
        Task {
            try await loginSuccessful(code: code, codeVerifier: verifier)
        }
    }

    public func didFailLoginWith(error: any Error) {}

    public func login() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await loginService.asWebAuthenticationLoginFrom(
                anchor: ASPresentationAnchor(),
                useEphemeralSession: true,
                hideCreateAccountButton: true
            )
            try await loginSuccessful(code: result.code, codeVerifier: result.verifier)
        } catch {
            loginFailed(error: error)
        }
    }

    func loginWith(accounts: [ConnectedAccount]) async {
        isLoading = true
        defer { isLoading = false }

        let managers: [Result<TransferManager, any Error>] = await accounts.asyncCompactMap { account in
            do {
                let derivatedToken = try await self.tokenService.derivateApiToken(for: account)

                let manager = try await self.accountManager.createAccount(token: derivatedToken)
                return .success(manager)
            } catch {
                return .failure(error)
            }
        }

        do {
            guard let firstManager = try managers.first?.get() else {
                error = .genericError
                return
            }

            await accountManager.setCurrentManager(manager: firstManager)
        } catch {
            self.error = .loginFailed(error: error)
        }
    }

    private func loginSuccessful(code: String, codeVerifier verifier: String) async throws {
        try await accountManager.createAndSetCurrentAccount(code: code, codeVerifier: verifier)
    }

    private func loginFailed(error: Error) {
        guard (error as? ASWebAuthenticationSessionError)?.code != .canceledLogin else { return }

        self.error = .loginFailed(error: error)
    }
}

public extension InfomaniakNetworkLoginable {
    private var deviceCheckEnvironment: InfomaniakDeviceCheck.Environment {
        switch ApiEnvironment.current {
        case .prod:
            return .prod
        case .preprod:
            return .preprod
        case .customHost(let host):
            return .init(url: URL(string: "https://\(host)/1/attest")!)
        }
    }

    func derivateApiToken(for account: ConnectedAccount) async throws -> ApiToken {
        try await derivateApiToken(account.token)
    }

    func derivateApiToken(_ token: ApiToken) async throws -> ApiToken {
        let attestationToken = try await InfomaniakDeviceCheck(environment: deviceCheckEnvironment)
            .generateAttestationFor(
                targetUrl: TargetAssembly.loginConfig.loginURL.appendingPathComponent("token"),
                bundleId: Constants.bundleId,
                bypassValidation: deviceCheckEnvironment == .preprod
            )

        let derivatedToken = try await derivateApiToken(
            using: token,
            attestationToken: attestationToken
        )

        return derivatedToken
    }
}
