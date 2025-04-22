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
    public func addBreadcrumb(message: String, category: String, level: STCore.CrashReportLevel, metadata: [String: Any]?) {
        Task {
            let sentryLevel = CrashLevelWrapper(crashReportLevel: level).sentryLevel
            let breadcrumb = Breadcrumb(level: sentryLevel, category: category)
            breadcrumb.message = message
            breadcrumb.data = metadata
            SentrySDK.addBreadcrumb(breadcrumb)
        }
    }

    public func capture(error: KotlinThrowable, context: [String: Any]?, contextKey: String?, extras: [String: Any]?) {
        Task {
            let errorWrapper = KotlinThrowableWrapper(kotlinThrowable: error)
            SentrySDK.capture(error: errorWrapper) { scope in
                if let context, let contextKey {
                    scope.setContext(value: context, key: contextKey)
                }

                if let extras {
                    scope.setExtras(extras)
                }
            }
        }
    }

    public func capture(
        message: String,
        context: [String: Any]?,
        contextKey: String?,
        level: STCore.CrashReportLevel?,
        extras: [String: Any]?
    ) {
        Task {
            SentrySDK.capture(message: message) { scope in
                if let context, let contextKey {
                    scope.setContext(value: context, key: contextKey)
                }

                if let level {
                    let sentryLevel = CrashLevelWrapper(crashReportLevel: level).sentryLevel
                    scope.setLevel(sentryLevel)
                }

                if let extras {
                    scope.setExtras(extras)
                }
            }
        }
    }
}
