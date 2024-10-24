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
import SwiftUI
import SwissTransferCore

struct DateSection: Identifiable, Equatable {
    static func == (lhs: DateSection, rhs: DateSection) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title // && lhs.transfers == rhs.transfers
    }

    let id: String
    let title: String
    let transfers: [TransferUi]

    init(sectionKey: String, transfers: [TransferUi]) {
        id = sectionKey
        title = ReferenceDate.titleFromRawSectionKey(sectionKey)
        self.transfers = transfers
    }
}

@MainActor
final class TransferListViewModel: ObservableObject {
    @Published var sections: [DateSection]?
    private var transfers: [TransferUi]

    init(transfers: [TransferUi]) {
        self.transfers = transfers
        mapSection(results: transfers)
    }

    private func mapSection(results: [TransferUi]) {
        Task {
            let results = Dictionary(grouping: results) { $0.sectionDate }
                .sorted {
                    guard let firstDate = $0.value.first?.date,
                          let secondDate = $1.value.first?.date else { return false }
                    return firstDate > secondDate
                }

            let mappedSections = results.map {
                let sectionTransfers = Array($0.value)
                return DateSection(sectionKey: $0.key, transfers: sectionTransfers)
            }

            withAnimation {
                self.sections = mappedSections
            }
        }
    }
}
