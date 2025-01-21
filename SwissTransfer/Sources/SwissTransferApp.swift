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

import InfomaniakCoreSwiftUI
import InfomaniakDI
import OSLog
import STCore
import STRootView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

@main
struct SwissTransferApp: App {
    // periphery:ignore - Making sure the Sentry is initialized at a very early stage of the app launch.
    private let sentryService = SentryService()
    // periphery:ignore - Making sure the DI is registered at a very early stage of the app launch.
    private let dependencyInjectionHook = TargetAssembly()

    @UIApplicationDelegateAdaptor private var appDelegateAdaptor: AppDelegate

    @LazyInjectService private var downloadManager: DownloadManager
    @LazyInjectService private var notificationsHelper: NotificationsHelper
    @LazyInjectService private var notificationCenterDelegate: NotificationCenterDelegate

    @StateObject private var appSettings: FlowObserver<AppSettings>
    @StateObject private var universalLinksState = UniversalLinksState()

    private var savedColorScheme: ColorScheme? {
        guard let appSettings = appSettings.value,
              let storedColorScheme = ColorScheme.from(appSettings.theme) else {
            return nil
        }

        return storedColorScheme
    }

    public init() {
        @InjectService var settings: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settings.appSettings))

        UNUserNotificationCenter.current().delegate = notificationCenterDelegate
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(universalLinksState)
                .environmentObject(downloadManager)
                .environmentObject(notificationCenterDelegate)
                .tint(.ST.primary)
                .ikButtonTheme(.swissTransfer)
                .detectCompactWindow()
                .preferredColorScheme(savedColorScheme)
                .onOpenURL(perform: handleURL)
                .sceneLifecycle(willEnterForeground: notificationsHelper.removeAllUploadNotifications)
        }
        .defaultAppStorage(.shared)
    }

    func handleURL(_ url: URL) {
        Task {
            guard let result = await UniversalLinkHandler().handlePossibleTransferURL(url) else {
                return
            }
            universalLinksState.linkedTransfer = result
        }
    }
}
