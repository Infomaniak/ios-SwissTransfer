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

import DeviceAssociation
import Foundation
import InAppTwoFactorAuthentication
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakDI
import InfomaniakLogin
import InterAppLogin
import OSLog
import STCore

private let appGroupIdentifier = "group.\(Constants.bundleId)"

public extension UserDefaults {
    static let shared = UserDefaults(suiteName: appGroupIdentifier)!
}

extension [Factory] {
    func registerFactoriesInDI() {
        forEach { SimpleResolver.sharedResolver.store(factory: $0) }
    }
}

/// Each target should subclass `TargetAssembly` and override `getTargetServices` to provide additional, target related, services.
@MainActor
open class TargetAssembly {
    static let logger = Logger(category: "TargetAssembly")

    private static let apiEnvironment = ApiEnvironment.prod
    public static let loginConfig = InfomaniakLogin.Config(
        clientId: "17EE3471-9843-4FB9-AD95-CB8C41BAD624",
        loginURL: URL(string: "https://login.\(apiEnvironment.host)/")!,
        accessType: nil
    )

    public init() {
        Self.setupDI()
    }

    open class func getCommonServices() -> [Factory] {
        return [
            Factory(type: AccountManagerable.self) { _, _ in
                AccountManager()
            },
            Factory(type: ConnectedAccountManagerable.self) { _, _ in
                ConnectedAccountManager(currentAppKeychainIdentifier: AppIdentifierBuilder.swissTransferKeychainIdentifier)
            },
            Factory(type: InfomaniakNetworkLoginable.self) { _, _ in
                InfomaniakNetworkLogin(config: loginConfig)
            },
            Factory(type: InfomaniakLoginable.self) { _, _ in
                InfomaniakLogin(config: loginConfig)
            },
            Factory(type: TokenStore.self) { _, _ in
                TokenStore()
            },
            Factory(type: DeviceManagerable.self) { _, _ in
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
                return DeviceManager(appGroupIdentifier: Constants.sharedAppGroupName,
                                     appMarketingVersion: version,
                                     capabilities: [.twoFactorAuthenticationChallengeApproval])
            },
            Factory(type: DownloadManager.self) { _, _ in
                let isRunningInAppClip = Bundle.main.bundleIdentifier == "com.infomaniak.swisstransfer.Clip"
                return DownloadManager(sessionConfiguration: isRunningInAppClip ? .swissTransfer : .swissTransferBackground)
            },
            Factory(type: ThumbnailProvidable.self) { _, _ in
                ThumbnailProvider()
            },
            Factory(type: SwissTransferInjection.self) { _, resolver in
                let groupPathProvider = try resolver.resolve(type: AppGroupPathProvidable.self,
                                                             forCustomTypeIdentifier: nil,
                                                             factoryParameters: nil,
                                                             resolver: resolver)

                let sentryWrapper = SentryKMPWrapper()

                let realmRootDirectory = groupPathProvider.realmRootURL.path()
                Logger.general.info("Realm group directory \(realmRootDirectory)")

                #if DEBUG
                return SwissTransferInjection(
                    environment: STCore.ApiEnvironment.Preprod(),
                    userAgent: UserAgentBuilder().userAgent,
                    databaseRootDirectory: realmRootDirectory,
                    crashReport: sentryWrapper
                )
                #else
                return SwissTransferInjection(
                    environment: STCore.ApiEnvironment.Prod(),
                    userAgent: UserAgentBuilder().userAgent,
                    databaseRootDirectory: realmRootDirectory,
                    crashReport: sentryWrapper
                )
                #endif
            },
            Factory(type: AppSettingsManager.self) { _, resolver in
                let stInjection = try resolver.resolve(type: SwissTransferInjection.self,
                                                       forCustomTypeIdentifier: nil,
                                                       factoryParameters: nil,
                                                       resolver: resolver)
                return stInjection.appSettingsManager
            },
            Factory(type: ReviewManageable.self) { _, _ in
                ReviewManager(userDefaults: UserDefaults.shared, actionBeforeFirstReview: 2)
            },
            Factory(type: AppGroupPathProvidable.self) { _, _ in
                guard let provider = AppGroupPathProvider(
                    realmRootPath: "database",
                    appGroupIdentifier: appGroupIdentifier
                ) else {
                    fatalError("could not safely init AppGroupPathProvider")
                }

                return provider
            },
            Factory(type: PlatformDetectable.self) { _, _ in
                PlatformDetector()
            },
            Factory(type: MatomoUtils.self) { _, _ in
                let matomo = MatomoUtils(siteId: MatomoUtils.siteID, baseURL: MatomoUtils.siteURL)
                #if DEBUG
                matomo.optOut(true)
                #endif
                return matomo
            },
            Factory(type: NotificationsHelper.self) { _, _ in
                NotificationsHelper()
            },
            Factory(type: NotificationCenterDelegate.self) { _, _ in
                NotificationCenterDelegate()
            }
        ]
    }

    open class func getTargetServices() -> [Factory] {
        logger.warning("targetServices is not implemented in subclass ? Did you forget to override ?")
        return []
    }

    public static func setupDI() {
        (getCommonServices() + getTargetServices()).registerFactoriesInDI()
    }
}
