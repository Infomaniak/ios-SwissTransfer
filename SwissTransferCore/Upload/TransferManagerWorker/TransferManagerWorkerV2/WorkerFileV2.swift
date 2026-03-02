/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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
import InfomaniakCore
import STCore

struct WorkerChunkInFileV2: Equatable, Sendable {
    let file: WorkerFileV2
    let chunk: WorkerChunkV2
    var task: Task<STNChunkEtag, Error>?

    static func == (lhs: WorkerChunkInFileV2, rhs: WorkerChunkInFileV2) -> Bool {
        lhs.chunk == rhs.chunk
    }
}

struct WorkerChunkV2: Equatable, Hashable, Sendable {
    let fileURL: URL
    let remoteUploadFileUUID: String
    let uploadUUID: String
    let range: DataRange
    let index: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
        hasher.combine(index)
    }

    static func == (lhs: WorkerChunkV2, rhs: WorkerChunkV2) -> Bool {
        lhs.fileURL == rhs.fileURL && lhs.index == rhs.index
    }
}

struct WorkerFileV2: Equatable, Sendable {
    let fileURL: URL
    let remoteUploadFileUUID: String
    let uploadChunks: [WorkerChunkV2]

    static func == (lhs: WorkerFileV2, rhs: WorkerFileV2) -> Bool {
        lhs.fileURL == rhs.fileURL
    }
}
