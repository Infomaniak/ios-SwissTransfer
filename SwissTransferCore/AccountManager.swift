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
import InAppTwoFactorAuthentication
import InfomaniakBugTracker
@preconcurrency import InfomaniakCore
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
    @LazyInjectService private var notificationService: InfomaniakNotifications
    @LazyInjectService private var bugTracker: BugTracker

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
            await enableBugTrackerIfAvailable()
        } catch {
            throw error
        }
    }

    public func createAccount(token: ApiToken) async throws {
        let temporaryApiFetcher = getApiFetcher(token: token)
        let user = try await userProfileStore.updateUserProfile(with: temporaryApiFetcher)

        let deviceId = try await deviceManager.getOrCreateCurrentDevice().uid
        tokenStore.addToken(newToken: token, associatedDeviceId: deviceId)
        attachDeviceToApiToken(token, apiFetcher: temporaryApiFetcher)
        await notificationService.updateTopicsIfNeeded([Topic.twoFAPushChallenge], userApiFetcher: temporaryApiFetcher)

        guard await (getSwissTransferManager(userId: user.id, token: token.accessToken)) != nil else {
            throw ErrorDomain.noUserSession
        }

        UserDefaults.shared.currentUserId = user.id
        objectWillChange.send()
    }

    @discardableResult
    public func updateUser(token: ApiToken) async throws -> UserProfile {
        let temporaryApiFetcher = getApiFetcher(token: token)
        return try await userProfileStore.updateUserProfile(with: temporaryApiFetcher)
    }

    public func getApiFetcher(token: ApiToken) -> ApiFetcher {
        return ApiFetcher(token: token, delegate: refreshTokenDelegate)
    }

    public func switchUser(newCurrentUserId: Int) async {
        UserDefaults.shared.currentUserId = newCurrentUserId
        await enableBugTrackerIfAvailable()
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

    private func getSwissTransferManager(userId: UserId, token: String?) async -> SwissTransferInjection? {
        _ = await loadUserTask?.result
        if let manager = managers[userId] {
            return manager
        } else {
            loadUserTask = Task {
                let injection = SwissTransferInjection()
                if userId > 0, let token {
                    try? await injection.accountManager.loadUser(user: STUserAuthUser(id: Int64(userId), token: token))
                } else {
                    try? await injection.accountManager.loadUser(user: STUserGuestUser.shared)
                }
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

        return await getUserSession(for: currentUserId)
    }

    public func getUserSession(for userId: Int) async -> UserSession? {
        if userId == AccountManager.guestUserId,
           let guestSwissTransferManager = await getSwissTransferManager(userId: AccountManager.guestUserId, token: nil) {
            return UserSession(
                userId: AccountManager.guestUserId,
                userProfile: nil,
                swissTransferManager: guestSwissTransferManager
            )
        }

        guard let token = tokenStore.tokenFor(userId: userId)?.apiToken,
              let swissTransferManager = await getSwissTransferManager(userId: userId, token: token.accessToken) else {
            return nil
        }

        if let userProfile = await userProfileStore.getUserProfile(id: userId) {
            return UserSession(userId: userId, userProfile: userProfile, swissTransferManager: swissTransferManager)
        } else {
            let temporaryApiFetcher = ApiFetcher(token: token, delegate: refreshTokenDelegate)
            if let userProfile = try? await userProfileStore.updateUserProfile(with: temporaryApiFetcher) {
                return UserSession(userId: userId, userProfile: userProfile, swissTransferManager: swissTransferManager)
            }
        }

        return nil
    }

    public func getAccountIds() async -> [UserId] {
        return Array(managers.keys)
    }

    public func removeTokenAndAccountFor(userId: Int) async {
        guard let removedToken = tokenStore.removeTokenFor(userId: userId) else { return }

        Task {
            await notificationService.removeStoredTokenFor(userId: userId)
        }

        let kmpAccountManager = await getSwissTransferManager(userId: userId, token: removedToken.accessToken)?.accountManager
        try? await kmpAccountManager?.logoutCurrentUser(newSTUser: nil)
        managers[userId] = nil
        objectWillChange.send()

        networkLoginService.deleteApiToken(token: removedToken) { result in
            guard case .failure(let error) = result else { return }
            Logger.general.error("Failed to delete api token: \(error.localizedDescription)")
        }
    }

    public func enableBugTrackerIfAvailable() async {
        if let currentUser = await userProfileStore.getUserProfile(id: UserDefaults.shared.currentUserId),
           let token = tokenStore.tokenFor(userId: currentUser.id),
           currentUser.isStaff == true {
            bugTracker.activateOnScreenshot()
            let apiFetcher = getApiFetcher(token: token.apiToken)
            bugTracker.configure(with: apiFetcher)
        } else {
            bugTracker.stopActivatingOnScreenshot()
        }
    }
}
