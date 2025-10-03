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
import Sentry
import STCore

public final class SentryKMPWrapper: CrashReportInterface {
    public func addBreadcrumb(
        message: String,
        category: String,
        level: CrashReportLevel,
        type: BreadcrumbType,
        data: [String: String]?
    ) {
        let breadcrumb = Breadcrumb(level: level.sentryLevel, category: category)
        breadcrumb.message = message
        breadcrumb.data = data
        breadcrumb.type = type.value
        SentrySDK.addBreadcrumb(breadcrumb)
    }

    public func capture(message: String, error: KotlinThrowable, data: [String: String]?) {
        let event = Event()
        event.message = SentryMessage(formatted: message)
        event.error = KotlinThrowableWrapper(kotlinThrowable: error)

        SentrySDK.capture(event: event) { scope in
            if let data {
                scope.setExtras(data)
            }
        }
    }

    public func capture(message: String, data: [String: String]?, level: STCore.CrashReportLevel?) {
        SentrySDK.capture(message: message) { scope in
            if let data {
                scope.setExtras(data)
            }
            if let level {
                scope.setLevel(level.sentryLevel)
            }
        }
    }
}
