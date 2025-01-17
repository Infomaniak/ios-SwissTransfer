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

extension TransferUi: Identifiable {
    public var id: String {
        uuid
    }
}

public extension TransferUi {
    var name: String {
        return date.formatted(.prettyDate)
    }

    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(createdDateTimestamp))
    }

    var sectionDate: String {
        if let sectionDateInterval = (ReferenceDate.allCases.first { $0.dateInterval.contains(date) }) {
            return sectionDateInterval.rawValue
        } else {
            return "\(date.startOfMonth.timeIntervalSince1970)"
        }
    }

    var detailDate: String {
        let refDate = ReferenceDate.allCases.first { $0.dateInterval.contains(date) }
        switch refDate {
        case .today, .yesterday:
            return refDate!.title
        default:
            return date.formatted(.prettyDate)
        }
    }

    var trimmedMessage: String? {
        return message?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var localArchiveURL: URL? {
        if files.count == 1,
           let fileURL = files.first?.localURL(in: self) {
            return fileURL
        }

        guard let transferContainerURL = try? URL.tmpDownloadsDirectory().appendingPathComponent("\(uuid)/") else {
            return nil
        }

        let filePaths = (try? FileManager.default.contentsOfDirectory(atPath: transferContainerURL.path())) ?? []
        for filePath in filePaths {
            guard (filePath as NSString).pathExtension == "zip" else {
                continue
            }

            return transferContainerURL.appending(path: filePath)
        }

        return nil
    }
}

public struct NavigableTransfer: Hashable {
    public static func == (lhs: NavigableTransfer, rhs: NavigableTransfer) -> Bool {
        return lhs.transfer.linkUUID == rhs.transfer.linkUUID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(transfer.linkUUID)
    }

    public let transfer: Transfer

    public init(transfer: Transfer) {
        self.transfer = transfer
    }
}
