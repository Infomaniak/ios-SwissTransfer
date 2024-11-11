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
import STResources
import STRootView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

@main
struct SwissTransferApp: App {
    private let sentryService = SentryService()
    private let dependencyInjectionHook = TargetAssembly()

    @LazyInjectService private var settingsManager: AppSettingsManager

    @StateObject var appSettings: FlowObserver<AppSettings>
    @Environment(\.colorScheme) var colorScheme

    var savedScheme: ColorScheme? {
        guard let appSettings = appSettings.value,
              let storedColorScheme = ColorScheme.from(appSettings.theme) else {
            return colorScheme
        }

        return storedColorScheme
    }

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(.ST.primary)
                .ikButtonTheme(.swissTransfer)
                .detectCompactWindow()
                .preferredColorScheme(savedScheme)
                .onOpenURL(perform: handleURL)
        }
    }

    func handleURL(_ url: URL) {
        Task {
            do {
                try await UniversalLinkHandler().handlePossibleTransferURL(url)
            } catch {
                Logger.view.error("Error while handling URL: \(error.localizedDescription)")
                throw UserFacingError.badTransferURL
                // TODO: Maybe have something like tryOrDisplayError in Mail to display snackbar
            }
        }
    }
}
