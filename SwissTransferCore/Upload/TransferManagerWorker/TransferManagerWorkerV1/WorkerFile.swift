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

struct WorkerChunkInFile: Equatable, Sendable {
    let file: WorkerFile
    let chunk: WorkerChunk
    var task: Task<Void, Error>?

    static func == (lhs: WorkerChunkInFile, rhs: WorkerChunkInFile) -> Bool {
        lhs.chunk == rhs.chunk
    }
}

struct WorkerChunk: Equatable, Hashable, Sendable {
    let fileURL: URL
    let remoteUploadFileUUID: String
    let uploadUUID: String
    let range: DataRange
    let index: Int
    let isLast: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
        hasher.combine(index)
    }

    static func == (lhs: WorkerChunk, rhs: WorkerChunk) -> Bool {
        lhs.fileURL == rhs.fileURL && lhs.index == rhs.index
    }
}

struct WorkerFile: Equatable, Sendable {
    let fileURL: URL
    let uploadChunks: [WorkerChunk]
    let lastChunk: WorkerChunk

    static func == (lhs: WorkerFile, rhs: WorkerFile) -> Bool {
        lhs.fileURL == rhs.fileURL
    }
}
