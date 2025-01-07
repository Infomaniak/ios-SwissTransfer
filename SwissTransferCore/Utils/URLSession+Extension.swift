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

public extension URLSession {
    static let sharedSwissTransfer = URLSession(configuration: .swissTransfer)
}

public extension URLSessionConfiguration {
    static let swissTransfer: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.httpAdditionalHeaders = ["User-Agent": UserAgentBuilder().userAgent]

        return configuration
    }()

    static let backgroundIdentifier = "background"
    static let swissTransferBackground: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.background(withIdentifier: URLSessionConfiguration.backgroundIdentifier)
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.isDiscretionary = false
        configuration.sessionSendsLaunchEvents = true
        configuration.httpAdditionalHeaders = ["User-Agent": UserAgentBuilder().userAgent]

        return configuration
    }()
}
