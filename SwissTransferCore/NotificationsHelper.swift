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
import OSLog
import STResources
import UserNotifications

public struct NotificationsHelper: Sendable {
    public enum CategoryIdentifier {
        public static let general = "com.infomaniak.swisstransfer.general"
        public static let upload = "com.infomaniak.swisstransfer.upload"
        public static let download = "com.infomaniak.swisstransfer.download"
    }

    private var immediateTrigger: UNTimeIntervalNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    }

    init() {}

    public func requestPermissionIfNeeded() async -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()

        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else {
            return settings.authorizationStatus == .authorized
        }

        let options: UNAuthorizationOptions = [.alert, .sound]
        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)
            return granted
        } catch {
            return false
        }
    }

    public func removeAllUploadNotifications() {
        Task {
            let notificationCenter = UNUserNotificationCenter.current()
            let uploadNotifications = await notificationCenter
                .deliveredNotifications()
                .filter { $0.request.content.categoryIdentifier == CategoryIdentifier.upload }

            notificationCenter.removeDeliveredNotifications(withIdentifiers: uploadNotifications.map(\.request.identifier))
        }
    }

    public func sendBackgroundUploadNotificationForUploadSession() {
        Task { @MainActor in
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = CategoryIdentifier.upload
            content.sound = .default
            content.title = STResourcesStrings.Localizable.uploadProgressIndication
            content.body = STResourcesStrings.Localizable.notificationKeepAppForegroundDescription

            let request = UNNotificationRequest(identifier: "upload_success", content: content, trigger: immediateTrigger)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    public func sendUploadFailedExpiredNotificationForUploadSession() {
        Task { @MainActor in
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = CategoryIdentifier.upload
            content.sound = .default
            content.title = STResourcesStrings.Localizable.notificationUploadFailureTitle
            content.body = STResourcesStrings.Localizable.notificationKeepAppForegroundDescription

            let request = UNNotificationRequest(identifier: "upload_failed", content: content, trigger: immediateTrigger)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
}
