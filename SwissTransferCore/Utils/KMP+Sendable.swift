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
import InfomaniakDeviceCheck
import STCore

// The following objects should be Sendable as discussed with the KMP team.
extension TransferUi: @retroactive @unchecked Sendable {}
extension FileUi: @retroactive @unchecked Sendable {}
extension NewUploadSession: @retroactive @unchecked Sendable {}

extension TransferManager: @retroactive @unchecked Sendable {}
extension UploadManager: @retroactive @unchecked Sendable {}
extension EmailTokensManager: @retroactive @unchecked Sendable {}
extension SharedApiUrlCreator: @retroactive @unchecked Sendable {}
extension STCore.AccountManager: @retroactive @unchecked Sendable {}
extension STNAuthorEmailToken: @retroactive @unchecked Sendable {}

@frozen public struct SendableUploadSession {
    public let uuid: String
    public let authorEmail: String
    public let authorEmailToken: String?
    public let files: [SendableUploadFileSession]

    init(uploadSession: any UploadSession) {
        uuid = uploadSession.uuid
        authorEmail = uploadSession.authorEmail
        authorEmailToken = uploadSession.authorEmailToken
        files = uploadSession.files.map { SendableUploadFileSession(uploadFileSession: $0) }
    }
}

@frozen public struct SendableUploadFileSession {
    public let localPath: String
    public let remoteUploadFile: SendableRemoteUploadFile?
    public let size: Int64

    init(uploadFileSession: any UploadFileSession) {
        localPath = uploadFileSession.localPath
        size = uploadFileSession.size

        if let remoteUploadFile = uploadFileSession.remoteUploadFile {
            self.remoteUploadFile = SendableRemoteUploadFile(remoteUploadFile: remoteUploadFile)
        } else {
            remoteUploadFile = nil
        }
    }
}

@frozen public struct SendableRemoteUploadFile {
    public let uuid: String

    init(remoteUploadFile: any RemoteUploadFile) {
        uuid = remoteUploadFile.uuid
    }
}
