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
    public func addBreadcrumb(message: String, category: String, level: STCore.CrashReportLevel, data: [String: Any]?) {
        let breadcrumb = Breadcrumb(level: level.sentryLevel, category: category)
        breadcrumb.message = message
        breadcrumb.data = data
        SentrySDK.addBreadcrumb(breadcrumb)
    }

    public func capture(error: KotlinThrowable, data context: [String: Any]?, category contextKey: String?) {
        let errorWrapper = KotlinThrowableWrapper(kotlinThrowable: error)
        SentrySDK.capture(error: errorWrapper) { scope in
            if let context, let contextKey {
                scope.setContext(value: context, key: contextKey)
            }
        }
    }

    public func capture(
        message: String,
        data context: [String: Any]?,
        category contextKey: String?,
        level: STCore.CrashReportLevel?
    ) {
        SentrySDK.capture(message: message) { scope in
            if let context, let contextKey {
                scope.setContext(value: context, key: contextKey)
            }

            if let level {
                scope.setLevel(level.sentryLevel)
            }
        }
    }
}
