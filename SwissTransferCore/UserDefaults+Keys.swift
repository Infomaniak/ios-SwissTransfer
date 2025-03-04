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
    static let matomoAuthorized = UserDefaults.Keys(rawValue: "matomoAuthorized")
    static let sentryAuthorized = UserDefaults.Keys(rawValue: "sentryAuthorized")
    static let transferCountKey = UserDefaults.Keys(rawValue: "transferCount")
    static let hasReviewedApp = UserDefaults.Keys(rawValue: "hasReviewedApp")
}

public extension UserDefaults {
    var isNotificationsNewTransfers: Bool {
        get {
            if object(forKey: key(.notificationsNewTransfers)) == nil {
                set(DefaultPreferences.notificationsNewTransfers, forKey: key(.notificationsNewTransfers))
            }
            return bool(forKey: key(.notificationsNewTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsNewTransfers))
        }
    }

    var isNotificationsDownloadInProgress: Bool {
        get {
            if object(forKey: key(.notificationsDownloadInProgress)) == nil {
                set(
                    DefaultPreferences.notificationsDownloadInProgress,
                    forKey: key(.notificationsDownloadInProgress)
                )
            }
            return bool(forKey: key(.notificationsDownloadInProgress))
        }
        set {
            set(newValue, forKey: key(.notificationsDownloadInProgress))
        }
    }

    var isNotificationsFinishedTransfers: Bool {
        get {
            if object(forKey: key(.notificationsFinishedTransfers)) == nil {
                set(DefaultPreferences.notificationsFinishedTransfers, forKey: key(.notificationsFinishedTransfers))
            }
            return bool(forKey: key(.notificationsFinishedTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsFinishedTransfers))
        }
    }

    var isNotificationsDownloadTransfers: Bool {
        get {
            if object(forKey: key(.notificationsDownloadTransfers)) == nil {
                set(DefaultPreferences.notificationsDownloadTransfers, forKey: key(.notificationsDownloadTransfers))
            }
            return bool(forKey: key(.notificationsDownloadTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsDownloadTransfers))
        }
    }

    var isNotificationsFailedTransfers: Bool {
        get {
            if object(forKey: key(.notificationsFailedTransfers)) == nil {
                set(DefaultPreferences.notificationsFailedTransfers, forKey: key(.notificationsFailedTransfers))
            }
            return bool(forKey: key(.notificationsFailedTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsFailedTransfers))
        }
    }

    var isNotificationsExpiredTransfers: Bool {
        get {
            if object(forKey: key(.notificationsExpiredTransfers)) == nil {
                set(DefaultPreferences.notificationsExpiredTransfers, forKey: key(.notificationsExpiredTransfers))
            }
            return bool(forKey: key(.notificationsExpiredTransfers))
        }
        set {
            set(newValue, forKey: key(.notificationsExpiredTransfers))
        }
    }

    var isMatomoAuthorized: Bool {
        get {
            if object(forKey: key(.matomoAuthorized)) == nil {
                set(DefaultPreferences.matomoAuthorized, forKey: key(.matomoAuthorized))
            }
            return bool(forKey: key(.matomoAuthorized))
        }
        set {
            set(newValue, forKey: key(.matomoAuthorized))
        }
    }

    var isSentryAuthorized: Bool {
        get {
            if object(forKey: key(.sentryAuthorized)) == nil {
                set(DefaultPreferences.sentryAuthorized, forKey: key(.sentryAuthorized))
            }
            return bool(forKey: key(.sentryAuthorized))
        }
        set {
            set(newValue, forKey: key(.sentryAuthorized))
        }
    }

    var transferCount: Int {
        get {
            integer(forKey: key(.transferCountKey))
        }
        set {
            set(newValue, forKey: key(.transferCountKey))
        }
    }

    var hasReviewedApp: Bool {
        get {
            bool(forKey: key(.hasReviewedApp))
        }
        set {
            set(newValue, forKey: key(.hasReviewedApp))
        }
    }
}
