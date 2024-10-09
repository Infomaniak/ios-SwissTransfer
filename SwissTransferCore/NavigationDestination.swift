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

import STCore

// TODO: Will be updated with the Settings item
public enum NavigationDestination: Hashable {
    case transfer(Transfer)
    case settings

    public static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.transfer(let leftTransfer), .transfer(let rightTransfer)):
            return leftTransfer.linkUUID == rightTransfer.linkUUID
        case (.settings, .settings):
            return true
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .transfer(let transfer):
            hasher.combine(transfer.linkUUID)
        case .settings:
            hasher.combine("settingsItem")
        }
    }
}
