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

import InfomaniakCore
import InfomaniakCoreSwiftUI
import InfomaniakDI
import OSLog
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

@main
struct SwissTransferAppClip: App {
    // periphery:ignore - Making sure the Sentry is initialized at a very early stage of the app launch.
    private let sentryService = SentryService()
    // periphery:ignore - Making sure the DI is registered at a very early stage of the app launch.
    private let dependencyInjectionHook = TargetAssembly()

    @LazyInjectService private var downloadManager: DownloadManager
    @LazyInjectService private var notificationCenterDelegate: NotificationCenterDelegate
    @LazyInjectService private var accountManager: SwissTransferCore.AccountManager

    @StateObject private var universalLinksState = UniversalLinksState()
    @StateObject private var rootViewState = RootViewState()

    init() {
        UNUserNotificationCenter.current().delegate = notificationCenterDelegate
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(universalLinksState)
                .environmentObject(downloadManager)
                .environmentObject(notificationCenterDelegate)
                .environmentObject(rootViewState)
                .environment(\.isRunningInAppClip, true)
                .tint(.ST.primary)
                .ikButtonTheme(.swissTransfer)
                .detectCompactWindow()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let url = activity.webpageURL else { return }
                    handleURL(url)
                }
                .onOpenURL(perform: handleURL)
                .sceneLifecycle(willEnterForeground: onWillEnterForeground)
        }
        .defaultAppStorage(.shared)
    }

    private func onWillEnterForeground() {
        Task {
            guard let currentManager = await accountManager.getCurrentManager() else {
                return
            }

            try await currentManager.tryUpdatingAllTransfers()
        }
    }

    func handleURL(_ url: URL) {
        Task {
            let linkHandler = UniversalLinkHandler()
            guard let universalLinkType = await linkHandler.handlePossibleUniversalLink(url: url) else { return }

            switch universalLinkType {
            case .importTransferFromExtension(let uuid):
                universalLinksState.linkedImportUUID = uuid
            case .openTransfer(let linkedTransfer):
                universalLinksState.linkedTransfer = linkedTransfer
            case .deleteTransfer(let linkedDeleteTransfer):
                universalLinksState.linkedDeleteTransfer = linkedDeleteTransfer
            }
        }
    }
}
