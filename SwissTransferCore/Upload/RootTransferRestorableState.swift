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

import Foundation
import OrderedCollections
import STCore

public struct RootTransferRestorableState: Sendable {
    public let authorEmail: String
    public let recipientsEmail: OrderedSet<String>
    public let transferType: TransferType
    public let password: String
    public let message: String
    public let title: String
    public let validityPeriod: ValidityPeriod
    public let downloadLimit: DownloadLimit
    public let emailLanguage: EmailLanguage

    init(uploadSession: any UploadSession) {
        authorEmail = uploadSession.authorEmail
        recipientsEmail = OrderedSet(uploadSession.recipientsEmails)

        if !recipientsEmail.isEmpty || !authorEmail.isEmpty {
            transferType = .mail
        } else {
            transferType = .link
        }

        password = uploadSession.password
        message = uploadSession.message
        title = ""
        validityPeriod = uploadSession.duration
        downloadLimit = uploadSession.numberOfDownload
        emailLanguage = uploadSession.language
    }

    init(uploadSessionRequest: UploadSessionRequest) {
        authorEmail = uploadSessionRequest.authorEmail
        recipientsEmail = OrderedSet(uploadSessionRequest.recipientsEmails)

        if !recipientsEmail.isEmpty || !authorEmail.isEmpty {
            transferType = .mail
        } else {
            transferType = .link
        }

        password = uploadSessionRequest.password
        message = uploadSessionRequest.message
        title = uploadSessionRequest.title ?? ""
        validityPeriod = uploadSessionRequest.validityPeriod
        downloadLimit = uploadSessionRequest.downloadCountLimit
        emailLanguage = uploadSessionRequest.languageCode
    }
}
