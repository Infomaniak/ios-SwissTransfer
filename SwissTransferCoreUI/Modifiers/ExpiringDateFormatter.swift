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
    public func format(_ value: Int64) -> AttributedString {
        let expiresIn = Date.expiresIn(timestamp: value)
        if expiresIn > 0 {
            return AttributedString(STResourcesStrings.Localizable.expiresIn(expiresIn))
        }

        let date = Date.expiresDate(timestamp: value).formatted(date: .numeric, time: .omitted)
        var result = AttributedString(STResourcesStrings.Localizable.expiredThe(date))
        result.foregroundColor = Color.ST.error
        return result
    }
}

public extension FormatStyle where Self == ExpiringDateFormat {
    static var expiring: ExpiringDateFormat { .init() }
}
