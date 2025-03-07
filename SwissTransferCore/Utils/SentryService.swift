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

import Sentry

public struct SentryService {
    public init() {
        initSentry()
    }

    private func initSentry() {
        SentrySDK.start { options in
            options.dsn = "https://200ddb73d9c67f455b0e2d190016715b@sentry-mobile.infomaniak.com/20"
            options.environment = Bundle.main.isRunningInTestFlight ? "testflight" : "production"
            options.tracePropagationTargets = []
            options.enableUIViewControllerTracing = false
            options.enableUserInteractionTracing = false
            options.enableNetworkTracking = false
            options.enableNetworkBreadcrumbs = false
            options.enableSwizzling = false // We can disable swizzling because we only used it for networking
            options.enableMetricKit = true

            options.beforeSend = { event in
                // if the application is in debug mode discard the events
                #if DEBUG || TEST
                return nil
                #else
                if UserDefaults.shared.isSentryAuthorized {
                    return event
                } else {
                    return nil
                }
                #endif
            }
        }
    }
}
