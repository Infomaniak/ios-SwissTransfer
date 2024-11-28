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