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

struct DownloadTaskCompletion {
    let id: String
    let result: Result<DownloadedFile, Error>
}

struct DownloadTaskProgress {
    let id: String
    let current: Int64
    let total: Int64
}

struct DownloadedFile {
    let filename: String
    let url: URL

    init(suggestedFilename: String?, url: URL) {
        if let filename = suggestedFilename {
            self.filename = filename
        } else {
            filename = url.lastPathComponent
        }
        self.url = url
    }
}
