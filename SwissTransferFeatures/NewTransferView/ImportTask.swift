/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

import CryptoKit
import Foundation
import SwissTransferCore

struct ImportTask {
    let id: UUID
    let task: Task<Void, Never>

    static func taskIdFor(items: [ImportedItem]) -> UUID {
        let data = Data(items.flatMap { withUnsafeBytes(of: $0.id, Array.init) })
        let hash = SHA256.hash(data: data)
        let uuidBytes = hash.prefix(16)
        return withUnsafeBytes(of: uuidBytes) {
            UUID(uuid: $0.load(as: uuid_t.self))
        }
    }
}
