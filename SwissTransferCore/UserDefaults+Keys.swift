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
import SwiftUI

public extension UserDefaults.Keys {
    static let notificationsNewTransfers = UserDefaults.Keys(rawValue: "notificationsNewTransfers")
    static let notificationsDownloadInProgress = UserDefaults.Keys(rawValue: "notificationsDownloadInProgress")
    static let notificationsFinishedTransfers = UserDefaults.Keys(rawValue: "notificationsFinishedTransfers")
    static let notificationsDownloadTransfers = UserDefaults.Keys(rawValue: "notificationsDownloadTransfers")
    static let notificationsFailedTransfers = UserDefaults.Keys(rawValue: "notificationsFailedTransfers")
    static let notificationsExpiredTransfers = UserDefaults.Keys(rawValue: "notificationsExpiredTransfers")
}

public extension UserDefaults {
    var isNotificationsNewTransfersEnabled: Bool {
        get {
            if object(forKey: key(.notificationsNewTransfers)) == nil {
                set(DefaultNotificationsPreferences.notificationsNewTransfers, forKey: key(.notificationsNewTransfers))
            }
            return bool(forKey: key(.notificationsNewTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsNewTransfers))
        }
    }

    var isNotificationsDownloadInProgressEnabled: Bool {
        get {
            if object(forKey: key(.notificationsDownloadInProgress)) == nil {
                set(
                    DefaultNotificationsPreferences.notificationsDownloadInProgress,
                    forKey: key(.notificationsDownloadInProgress)
                )
            }
            return bool(forKey: key(.notificationsDownloadInProgress))
        }
        set {
            set(newValue, forKey: key(.notificationsDownloadInProgress))
        }
    }

    var isNotificationsFinishedTransfersEnabled: Bool {
        get {
            if object(forKey: key(.notificationsFinishedTransfers)) == nil {
                set(DefaultNotificationsPreferences.notificationsFinishedTransfers, forKey: key(.notificationsFinishedTransfers))
            }
            return bool(forKey: key(.notificationsFinishedTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsFinishedTransfers))
        }
    }

    var isNotificationsDownloadTransfersEnabled: Bool {
        get {
            if object(forKey: key(.notificationsDownloadTransfers)) == nil {
                set(DefaultNotificationsPreferences.notificationsDownloadTransfers, forKey: key(.notificationsDownloadTransfers))
            }
            return bool(forKey: key(.notificationsDownloadTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsDownloadTransfers))
        }
    }

    var isNotificationsFailedTransfersEnabled: Bool {
        get {
            if object(forKey: key(.notificationsFailedTransfers)) == nil {
                set(DefaultNotificationsPreferences.notificationsFailedTransfers, forKey: key(.notificationsFailedTransfers))
            }
            return bool(forKey: key(.notificationsFailedTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsFailedTransfers))
        }
    }

    var isNotificationsExpiredTransfersEnabled: Bool {
        get {
            if object(forKey: key(.notificationsExpiredTransfers)) == nil {
                set(DefaultNotificationsPreferences.notificationsExpiredTransfers, forKey: key(.notificationsExpiredTransfers))
            }
            return bool(forKey: key(.notificationsExpiredTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsExpiredTransfers))
        }
    }
}
