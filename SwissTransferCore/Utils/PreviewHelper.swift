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

public enum PreviewHelper {
    public static let sampleFile: File = PreviewFile(
        containerUUID: "containerUUID",
        createdDateTimestamp: 0,
        deletedDate: nil,
        downloadCounter: 0,
        eVirus: "",
        expiredDateTimestamp: 0,
        fileName: "Nom du fichier",
        fileSizeInBytes: 0,
        mimeType: "image/jpeg",
        path: nil,
        receivedSizeInBytes: 0,
        uuid: "uuid"
    )

    public static let sampleContainer: Container = PreviewContainer(
        createdDateTimestamp: 0,
        deletedDateTimestamp: 0,
        downloadLimit: 0,
        duration: 0,
        expiredDateTimestamp: 0,
        files: [sampleFile, sampleFile, sampleFile],
        lang: "fr",
        message: "Rapport d'oral - Master 2",
        needPassword: 0,
        numberOfFile: 3,
        sizeUploaded: 0,
        source: "",
        swiftVersion: 0,
        uuid: "uuid"
    )

    public static let sampleTransfer: Transfer = PreviewTransfer(
        container: sampleContainer,
        containerUUID: sampleContainer.uuid,
        createdDateTimestamp: 1_723_960_169,
        downloadCounterCredit: 0,
        downloadHost: "",
        expiredDateTimestamp: 0,
        isDownloadOnetime: 0,
        isMailSent: true,
        linkUUID: "linkUUID"
    )

    public static let sampleOldTransfer: Transfer = PreviewTransfer(
        container: sampleContainer,
        containerUUID: sampleContainer.uuid,
        createdDateTimestamp: 1_714_160_797,
        downloadCounterCredit: 0,
        downloadHost: "",
        expiredDateTimestamp: 0,
        isDownloadOnetime: 0,
        isMailSent: true,
        linkUUID: "linkUUID"
    )
}

private class PreviewFile: File {
    var containerUUID: String
    var createdDateTimestamp: Int64
    var deletedDate: String?
    var downloadCounter: Int64
    var eVirus: String
    var expiredDateTimestamp: Int64
    var fileName: String
    var fileSizeInBytes: Int64
    var mimeType: String
    var path: String?
    var receivedSizeInBytes: Int64
    var uuid: String

    init(
        containerUUID: String,
        createdDateTimestamp: Int64,
        deletedDate: String? = nil,
        downloadCounter: Int64,
        eVirus: String,
        expiredDateTimestamp: Int64,
        fileName: String,
        fileSizeInBytes: Int64,
        mimeType: String,
        path: String? = nil,
        receivedSizeInBytes: Int64,
        uuid: String
    ) {
        self.containerUUID = containerUUID
        self.createdDateTimestamp = createdDateTimestamp
        self.deletedDate = deletedDate
        self.downloadCounter = downloadCounter
        self.eVirus = eVirus
        self.expiredDateTimestamp = expiredDateTimestamp
        self.fileName = fileName
        self.fileSizeInBytes = fileSizeInBytes
        self.mimeType = mimeType
        self.path = path
        self.receivedSizeInBytes = receivedSizeInBytes
        self.uuid = uuid
    }
}

private class PreviewContainer: Container {
    var createdDateTimestamp: Int64
    var deletedDateTimestamp: KotlinLong?
    var downloadLimit: Int64
    var duration: Int64
    var expiredDateTimestamp: Int64
    var files: [any File]
    var lang: String
    var message: String?
    var needPassword: Int64
    var numberOfFile: Int64
    var sizeUploaded: Int64
    var source: String
    var swiftVersion: Int64
    var uuid: String

    init(
        createdDateTimestamp: Int64,
        deletedDateTimestamp: KotlinLong? = nil,
        downloadLimit: Int64,
        duration: Int64,
        expiredDateTimestamp: Int64,
        files: [any File],
        lang: String,
        message: String? = nil,
        needPassword: Int64,
        numberOfFile: Int64,
        sizeUploaded: Int64,
        source: String,
        swiftVersion: Int64,
        uuid: String
    ) {
        self.createdDateTimestamp = createdDateTimestamp
        self.deletedDateTimestamp = deletedDateTimestamp
        self.downloadLimit = downloadLimit
        self.duration = duration
        self.expiredDateTimestamp = expiredDateTimestamp
        self.files = files
        self.lang = lang
        self.message = message
        self.needPassword = needPassword
        self.numberOfFile = numberOfFile
        self.sizeUploaded = sizeUploaded
        self.source = source
        self.swiftVersion = swiftVersion
        self.uuid = uuid
    }
}

private class PreviewTransfer: Transfer {
    var container: Any?
    var containerUUID: String
    var createdDateTimestamp: Int64
    var downloadCounterCredit: Int64
    var downloadHost: String
    var expiredDateTimestamp: Int64
    var isDownloadOnetime: Int64
    var isMailSent: Bool
    var linkUUID: String

    init(
        container: Any? = nil,
        containerUUID: String,
        createdDateTimestamp: Int64,
        downloadCounterCredit: Int64,
        downloadHost: String,
        expiredDateTimestamp: Int64,
        isDownloadOnetime: Int64,
        isMailSent: Bool,
        linkUUID: String
    ) {
        self.container = container
        self.containerUUID = containerUUID
        self.createdDateTimestamp = createdDateTimestamp
        self.downloadCounterCredit = downloadCounterCredit
        self.downloadHost = downloadHost
        self.expiredDateTimestamp = expiredDateTimestamp
        self.isDownloadOnetime = isDownloadOnetime
        self.isMailSent = isMailSent
        self.linkUUID = linkUUID
    }
}
