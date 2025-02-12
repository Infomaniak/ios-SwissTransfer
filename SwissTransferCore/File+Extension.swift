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
import OSLog
import STCore

extension FileUi: DisplayableFile {}

public extension FileUi {
    func localURLFor(transferUUID: String) -> URL? {
        return try? URL.tmpDownloadsDirectory()
            .appendingPathComponent("\(transferUUID)/")
            .appendingPathComponent("\(uid)/")
            .appendingPathComponent(fileName)
    }

    func localURLFor(transfer: TransferUi) -> URL? {
        localURLFor(transferUUID: transfer.uuid)
    }
}
