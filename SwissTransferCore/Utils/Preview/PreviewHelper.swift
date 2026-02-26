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
import InfomaniakCore
import STCore

public enum PreviewHelper {
    public static let sampleFolder = FileUi(
        uid: "folderUUID",
        fileName: "Folder name",
        path: nil,
        isFolder: true,
        fileSize: 8561,
        mimeType: nil,
        localPath: nil,
        thumbnailPath: nil
    )

    public static let sampleFile = FileUi(
        uid: "fileUUID",
        fileName: "File name",
        path: nil,
        isFolder: false,
        fileSize: 8561,
        mimeType: "imge/jpeg",
        localPath: nil,
        thumbnailPath: nil
    )

    public static let sampleTransfer = TransferUi(
        uuid: "transferUUID",
        createdDateTimestamp: 1_723_960_169,
        expirationDateTimestamp: expireTimeStamp(expired: false),
        sizeUploaded: 8123,
        downloadLimit: 250,
        downloadLeft: 249,
        message: "Some message",
        password: nil,
        recipientsEmails: Set(),
        files: [sampleFile],
        direction: .received,
        transferStatus: .ready,
        apiSource: .v1
    )

    public static let sampleOldTransfer = TransferUi(
        uuid: "oldTransferUUID",
        createdDateTimestamp: 1_714_160_797,
        expirationDateTimestamp: expireTimeStamp(expired: true),
        sizeUploaded: 8123,
        downloadLimit: 250,
        downloadLeft: 249,
        message: "Some message",
        password: nil,
        recipientsEmails: Set(),
        files: [sampleFile],
        direction: .received,
        transferStatus: .ready,
        apiSource: .v1
    )

    public static let sampleUser = UserProfile(
        id: 1,
        displayName: "John Appleseed",
        firstName: "John",
        lastName: "Appleseed",
        email: "mobiletest@ik.me",
        avatar: "https://avatar.storage.infomaniak.com/AXo01iecwUeoGoydY7WaCmmG.png?1717510064"
    )

    public static let sampleNewUploadSession = NewUploadSession(
        duration: ValidityPeriod.thirty,
        authorEmail: "",
        authorEmailToken: nil,
        password: "",
        message: "Coucou",
        numberOfDownload: DownloadLimit.twoHundredFifty,
        language: .english,
        recipientsEmails: [],
        files: []
    )

    public static let sampleSendableUploadSession = SendableUploadSession(uploadSession: sampleNewUploadSession)

    public static let sampleListOfRecipients: [String] = {
        let recipients = Array(repeating: "short@ik.me", count: 2)
            + Array(repeating: "long-email@infomaniak.com", count: 2)
            + Array(repeating: "middle@infomaniak.com", count: 3)
        return recipients.shuffled()
    }()

    private static func expireTimeStamp(expired: Bool) -> Int64 {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let days = expired ? -4 : 4
        let expireDate = calendar.date(byAdding: DateComponents(calendar: calendar, day: days), to: date)
        return Int64(expireDate?.timeIntervalSince1970 ?? 0)
    }
}
