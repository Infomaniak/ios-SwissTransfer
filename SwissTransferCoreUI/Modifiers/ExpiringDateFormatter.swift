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

import STResources
import SwiftUI
import SwissTransferCore

public struct ExpiringDateFormat: FormatStyle {
    let completeDate: Bool

    public func format(_ value: Int64) -> String {
        if completeDate {
            return completeExpiration(value)
        } else {
            return shortExpiration(value)
        }
    }

    private func completeExpiration(_ value: Int64) -> String {
        let expirationDate = Date.expiresDate(timestamp: value)
        let dateFormatted = expirationDate.formatted(date: .numeric, time: .shortened)

        return STResourcesStrings.Localizable.expiresThe(dateFormatted)
    }

    private func shortExpiration(_ value: Int64) -> String {
        let expirationDate = Date.expiresDate(timestamp: value)
        let dateFormatted = expirationDate.formatted(date: .numeric, time: .omitted)
        let timeFormatted = expirationDate.formatted(date: .omitted, time: .shortened)

        let daysBeforeExpiration = Date.expiresIn(timestamp: value)
        if daysBeforeExpiration > 1 {
            return STResourcesStrings.Localizable.expiresIn(daysBeforeExpiration)
        } else if daysBeforeExpiration == 1 {
            return STResourcesStrings.Localizable.expiresTomorrow
        }

        return STResourcesStrings.Localizable.expiresAt(timeFormatted)
    }
}

public extension FormatStyle where Self == ExpiringDateFormat {
    static var expiring: ExpiringDateFormat { .init(completeDate: false) }
    static var completeExpiring: ExpiringDateFormat { .init(completeDate: true) }
}
