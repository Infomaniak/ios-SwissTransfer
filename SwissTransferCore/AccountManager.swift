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

import Combine
import DeviceAssociation
import Foundation
import InfomaniakCore
import InfomaniakDI
import InfomaniakLogin
import InfomaniakNotifications
import OSLog
import STCore

public extension AccountManager {
    enum ErrorDomain: Error {
        case noUserSession
    }
}

public extension ApiFetcher {
    convenience init(token: ApiToken, delegate: RefreshTokenDelegate) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.init(decoder: decoder)
        createAuthenticatedSession(
            token,
            authenticator: OAuthAuthenticator(refreshTokenDelegate: delegate),
            additionalAdapters: [UserAgentAdapter()]
        )
    }
}

public final class STRefreshTokenDelegate: InfomaniakCore.RefreshTokenDelegate, Sendable {
    public func didUpdateToken(newToken: ApiToken, oldToken: ApiToken) {}

    public func didFailRefreshToken(_ token: ApiToken) {}
}

public actor AccountManager: ObservableObject {
    public typealias UserId = Int

    @LazyInjectService private var tokenStore: TokenStore
    @LazyInjectService private var deviceManager: DeviceManagerable
    @LazyInjectService private var networkLoginService: InfomaniakNetworkLoginable

    /// In case we later choose to support multi account / login we simulate an existing guest
    static let guestUserId = -1

    public let userProfileStore = UserProfileStore()

    private let refreshTokenDelegate = STRefreshTokenDelegate()

    private var managers = [UserId: SwissTransferInjection]()

    private var loadUserTask: Task<Void?, Never>?

    init() {}

    public func createAndSetCurrentAccount() {
        UserDefaults.shared.currentUserId = AccountManager.guestUserId
        objectWillChange.send()
    }

    public func createAndSetCurrentAccount(code: String, codeVerifier: String) async throws {
        let token = try await networkLoginService.apiTokenUsing(code: code, codeVerifier: codeVerifier)

        do {
            try await createAccount(token: token)
        } catch {
            throw error
        }
    }

    public func createAccount(token: ApiToken) async throws {
        let temporaryApiFetcher = ApiFetcher(token: token, delegate: refreshTokenDelegate)
        let user = try await userProfileStore.updateUserProfile(with: temporaryApiFetcher)

        let deviceId = try await deviceManager.getOrCreateCurrentDevice().uid
        tokenStore.addToken(newToken: token, associatedDeviceId: deviceId)
        attachDeviceToApiToken(token, apiFetcher: temporaryApiFetcher)

        guard await (getSwissTransferManager(userId: user.id, token: token.accessToken)) != nil else {
            throw ErrorDomain.noUserSession
        }

        UserDefaults.shared.currentUserId = user.id
        objectWillChange.send()
    }

    private func attachDeviceToApiToken(_ token: ApiToken, apiFetcher: ApiFetcher) {
        Task {
            do {
                let device = try await deviceManager.getOrCreateCurrentDevice()
                try await deviceManager.attachDeviceIfNeeded(device, to: token, apiFetcher: apiFetcher)
            } catch {
                Logger.general.error("Failed to attach device to token: \(error.localizedDescription)")
            }
        }
    }

    // periphery:ignore - Token will be used with new multi account
    private func getSwissTransferManager(userId: UserId, token: String?) async -> SwissTransferInjection? {
        _ = await loadUserTask?.result
        if let manager = managers[userId] {
            return manager
        } else {
            loadUserTask = Task {
                let injection = SwissTransferInjection()
                try? await injection.accountManager.loadUser(userId: Int32(AccountManager.guestUserId))
                managers[userId] = injection
            }
            _ = await loadUserTask?.result
            loadUserTask = nil

            return managers[userId]
        }
    }

    public func getCurrentUserSession() async -> UserSession? {
        let currentUserId = UserDefaults.shared.currentUserId

        guard currentUserId > 0 || currentUserId == AccountManager.guestUserId else {
            return nil
        }

        if currentUserId == AccountManager.guestUserId,
           let guestSwissTransferManager = await getSwissTransferManager(userId: AccountManager.guestUserId, token: nil) {
            return UserSession(
                userId: AccountManager.guestUserId,
                userProfile: nil,
                swissTransferManager: guestSwissTransferManager
            )
        }

        guard let token = tokenStore.tokenFor(userId: currentUserId)?.apiToken,
              let swissTransferManager = await getSwissTransferManager(userId: currentUserId, token: token.accessToken) else {
            return nil
        }

        if let userProfile = await userProfileStore.getUserProfile(id: currentUserId) {
            return UserSession(userId: currentUserId, userProfile: userProfile, swissTransferManager: swissTransferManager)
        } else {
            let temporaryApiFetcher = ApiFetcher(token: token, delegate: refreshTokenDelegate)
            if let userProfile = try? await userProfileStore.updateUserProfile(with: temporaryApiFetcher) {
                return UserSession(userId: currentUserId, userProfile: userProfile, swissTransferManager: swissTransferManager)
            }
        }

        return nil
    }

    public func getAccountIds() async -> [UserId] {
        return Array(managers.keys)
    }

    public func removeTokenAndAccountFor(userId: Int) {
        guard let removedToken = tokenStore.removeTokenFor(userId: userId) else { return }

        objectWillChange.send()

        networkLoginService.deleteApiToken(token: removedToken) { result in
            guard case .failure(let error) = result else { return }
            Logger.general.error("Failed to delete api token: \(error.localizedDescription)")
        }
    }
}
