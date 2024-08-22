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

// TODO: - Move to InfomaniakCore ?
extension Date {
    func toString(withTime: Bool = true) -> String {
        return formatted(date: .long, time: withTime ? .shortened : .omitted)
    }

    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }

    static var lastWeek: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now)!
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }

    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }

    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.month, .year], from: self))!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}

public enum ReferenceDate: String, CaseIterable {
    case today, yesterday, thisWeek, lastWeek, thisMonth

    public var dateInterval: DateInterval {
        switch self {
        case .today:
            return .init(start: .now.startOfDay, duration: Constants.numberOfSecondsInADay)
        case .yesterday:
            return .init(start: .yesterday.startOfDay, duration: Constants.numberOfSecondsInADay)
        case .thisWeek:
            return .init(start: .now.startOfWeek, end: .now.endOfWeek)
        case .lastWeek:
            return .init(start: .lastWeek.startOfWeek, end: .lastWeek.endOfWeek)
        case .thisMonth:
            return .init(start: .now.startOfMonth, end: .now.endOfMonth)
        }
    }

    public static func titleFromRawSectionKey(_ rawKey: String) -> String {
        if let referenceDate = ReferenceDate(rawValue: rawKey) {
            return referenceDate.title
        }

        guard let timeInterval = Double(rawKey) else { return "" }
        let referenceDate = Date(timeIntervalSince1970: timeInterval)

        var formatStyle = Date.FormatStyle.dateTime.month(.wide)
        if !Calendar.current.isDate(referenceDate, equalTo: .now, toGranularity: .year) {
            formatStyle = formatStyle.year()
        }
        return referenceDate.formatted(formatStyle).capitalized
    }

    public var title: String {
        switch self {
        case .today:
            return STResourcesStrings.Localizable.transferListSectionToday
        case .yesterday:
            return STResourcesStrings.Localizable.transferListSectionYesterday
        case .thisWeek:
            return STResourcesStrings.Localizable.transferListSectionThisWeek
        case .lastWeek:
            return STResourcesStrings.Localizable.transferListSectionLastWeek
        case .thisMonth:
            return STResourcesStrings.Localizable.transferListSectionThisMonth
        }
    }
}
