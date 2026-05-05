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
@preconcurrency import InfomaniakCore
import InfomaniakDI
import InfomaniakNotifications
import SwissTransferCore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        guard identifier == URLSessionConfiguration.backgroundIdentifier else { return }

        @InjectService var downloadManager: DownloadManager
        downloadManager.backgroundDownloadCompletionCallback = completionHandler
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            @InjectService var notificationService: InfomaniakNotifications
            @InjectService var accountManager: AccountManager
            @InjectService var tokenStore: TokenStore

            let tokens = tokenStore.getAllTokens()
            for (_, token) in tokens {
                Task {
                    /* Because of a backend issue we can't register the notification token directly after the creation or refresh of
                     an API token. We wait at least 15 seconds before trying to register. */
                    try? await Task.sleep(nanoseconds: 15_000_000_000)

                    let userApiFetcher = await accountManager.getApiFetcher(token: token.apiToken)
                    await notificationService.updateRemoteNotificationsToken(tokenData: deviceToken,
                                                                             userApiFetcher: userApiFetcher,
                                                                             updatePolicy: .always)
                }
            }
        }
    }
}
