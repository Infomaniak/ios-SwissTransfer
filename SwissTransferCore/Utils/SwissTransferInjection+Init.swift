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

import Foundation
import InfomaniakCore
import InfomaniakDI
import OSLog
import STCore

extension SwissTransferInjection {
    convenience init() {
        @InjectService var groupPathProvider: AppGroupPathProvidable
        let sentryWrapper = SentryKMPWrapper()

        let realmRootDirectory = groupPathProvider.realmRootURL.path()
        let roomPath = groupPathProvider.realmRootURL.appending(path: "transfers").path()
        Logger.general.info("Realm group directory \(realmRootDirectory)")

        #if DEBUG
        self.init(
            environment: STCore.ApiEnvironment.Preprod(),
            userAgent: UserAgentBuilder().userAgent,
            databaseRootDirectory: realmRootDirectory,
            crashReport: sentryWrapper,
            databaseConfig: .init(databaseRootDirectory: roomPath)
        )
        #else
        self.init(
            environment: STCore.ApiEnvironment.Prod(),
            userAgent: UserAgentBuilder().userAgent,
            databaseRootDirectory: realmRootDirectory,
            crashReport: sentryWrapper,
            databaseConfig: .init(databaseRootDirectory: roomPath)
        )
        #endif
    }
}
