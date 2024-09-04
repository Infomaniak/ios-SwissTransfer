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
import InfomaniakDI
import OSLog
import STCore

private let appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
private let appGroupIdentifier = "group.com.infomaniak.swisstransfer"

public extension UserDefaults {
    static let shared = UserDefaults(suiteName: appGroupIdentifier)!
}

extension [Factory] {
    func registerFactoriesInDI() {
        forEach { SimpleResolver.sharedResolver.store(factory: $0) }
    }
}

/// Each target should subclass `TargetAssembly` and override `getTargetServices` to provide additional, target related, services.
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
            Factory(type: SwissTransferInjection.self) { _, _ in
                SwissTransferInjection()
            },
            Factory(type: AppSettingsManager.self) { _, resolver in
                let stInjection = try resolver.resolve(type: SwissTransferInjection.self,
                                                       forCustomTypeIdentifier: nil,
                                                       factoryParameters: nil,
                                                       resolver: resolver)
                return stInjection.appSettingsManager
},
            Factory(type: AppGroupPathProvidable.self) { _, _ in
                guard let provider = AppGroupPathProvider(
                    realmRootPath: "",
                    appGroupIdentifier: appGroupIdentifier
                ) else {
                    fatalError("could not safely init AppGroupPathProvider")
                }

                return provider
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
