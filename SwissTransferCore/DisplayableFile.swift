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

public protocol DisplayableFile: Identifiable, Hashable {
    var uid: String { get }
    var isFolder: Bool { get }
    var fileName: String { get }
    var fileSize: Int64 { get }
    var mimeType: String? { get }

    func localURLFor(transferUUID: String) -> URL?
}

public extension DisplayableFile {
    func existsLocally(transferUUID: String?) -> Bool {
        guard let url = localURLFor(transferUUID: transferUUID ?? "") else {
            return false
        }

        return FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }
}

public extension DisplayableFile {
    var id: String { uid }
}
