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
import STCore
import SwissTransferCore

final class DateSection: Identifiable, Equatable {
    static func == (lhs: DateSection, rhs: DateSection) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title // && lhs.transfers == rhs.transfers
    }

    let id: String
    let title: String
    let transfers: [Transfer]

    init(sectionKey: String, transfers: [Transfer]) {
        id = sectionKey
        title = ReferenceDate.titleFromRawSectionKey(sectionKey)
        self.transfers = transfers
    }
}

final class TransferListViewModel: ObservableObject {
    @Published var sections: [DateSection]?
    var transfers: [Transfer]

    init(transfers: [Transfer]) {
        self.transfers = transfers
        sections = mapSection(results: transfers)
    }

    private func mapSection(results: [Transfer]) -> [DateSection] {
        let results = Dictionary(grouping: results) { $0.sectionDate }
            .sorted {
                guard let firstDate = $0.value.first?.date,
                      let secondDate = $1.value.first?.date else { return false }
                return firstDate > secondDate
            }

        return results.map {
            let sectionTransfers = Array($0.value)
            return DateSection(sectionKey: $0.key, transfers: sectionTransfers)
        }
    }
}
