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
import STResources

public final class NotificationSettings {
    public init() {}

    let keys = [
        UserDefaults.shared.key(.notificationsNewTransfers),
        UserDefaults.shared.key(.notificationsDownloadInProgress),
        UserDefaults.shared.key(.notificationsFinishedTransfers),
        UserDefaults.shared.key(.notificationsDownloadTransfers),
        UserDefaults.shared.key(.notificationsFailedTransfers),
        UserDefaults.shared.key(.notificationsExpiredTransfers)
    ]

    public var allEnabled: Bool {
        guard let firstKey = keys.first,
              UserDefaults.standard.value(forKey: firstKey) != nil else {
            return true
        }
        let oneValueIsFalse = keys.contains { key in
            return !UserDefaults.standard.bool(forKey: key)
        }
        return !oneValueIsFalse
    }

    public var enabledNotificationLabel: String {
        if allEnabled {
            STResourcesStrings.Localizable.settingsAllNotifications
        } else {
            STResourcesStrings.Localizable.settingsCustomizedNotifications
        }
    }
}
