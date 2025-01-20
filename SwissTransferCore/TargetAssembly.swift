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
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakDI
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

    public init() {
        Self.setupDI()
    }

    open class func getCommonServices() -> [Factory] {
        return [
            Factory(type: AccountManager.self) { _, _ in
                AccountManager()
            },
            Factory(type: DownloadManager.self) { _, _ in
                DownloadManager()
            },
            Factory(type: SwissTransferInjection.self) { _, resolver in
                let groupPathProvider = try resolver.resolve(type: AppGroupPathProvidable.self,
                                                             forCustomTypeIdentifier: nil,
                                                             factoryParameters: nil,
                                                             resolver: resolver)

                let realmRootDirectory = groupPathProvider.realmRootURL.path()
                Logger.general.info("Realm group directory \(realmRootDirectory)")

                #if DEBUG
                return SwissTransferInjection(
                    environment: STCore.ApiEnvironment.Preprod(),
                    userAgent: UserAgentBuilder().userAgent,
                    databaseRootDirectory: realmRootDirectory
                )
                #else
                return SwissTransferInjection(
                    environment: STCore.ApiEnvironment.Prod(),
                    userAgent: UserAgentBuilder().userAgent,
                    databaseRootDirectory: realmRootDirectory
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
                ReviewManager(userDefaults: UserDefaults.shared)
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
            Factory(type: NotificationsHelper.self) { _,_ in
                NotificationsHelper()
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
