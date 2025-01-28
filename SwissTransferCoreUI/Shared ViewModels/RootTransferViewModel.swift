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
import InfomaniakDI
import OrderedCollections
import STCore
import SwissTransferCore

@MainActor
public final class RootTransferViewModel: ObservableObject {
    public static let minPasswordLength = 6
    public static let maxPasswordLength = 25

    @Published public var transferType = TransferType.qrCode
    @Published public var authorEmail = ""
    public var authorEmailToken: String?
    @Published public var recipientsEmail = OrderedSet<String>()
    @Published public var message = ""
    @Published public var password = ""
    @Published public var validityPeriod = ValidityPeriod.thirty
    @Published public var downloadLimit = DownloadLimit.twoHundredFifty
    @Published public var emailLanguage = EmailLanguage.french
    @Published public var files = [TransferableFile]()

    public private(set) var initializedFromShare: Bool

    public var isNewTransferValid: Bool {
        if files.isEmpty {
            return false
        }

        if !password.isEmpty && (password.count < Self.minPasswordLength || password.count > Self.maxPasswordLength) {
            return false
        }

        if transferType == .mail {
            if authorEmail.isEmpty || !EmailChecker(email: authorEmail).validate() {
                return false
            }

            if recipientsEmail.isEmpty {
                return false
            }
        }

        return true
    }

    public init(initializedFromShare: Bool = false) {
        self.initializedFromShare = initializedFromShare
        fetchValuesFromSettings()
    }

    private func fetchValuesFromSettings() {
        @InjectService var settingsManager: AppSettingsManager
        guard let appSettings = settingsManager.getAppSettings() else { return }

        transferType = appSettings.lastTransferType
        authorEmail = appSettings.lastAuthorEmail ?? ""
        validityPeriod = appSettings.validityPeriod
        downloadLimit = appSettings.downloadLimit
        emailLanguage = appSettings.emailLanguage
    }

    public func toNewUploadSessionWith(_ newTransferFileManager: NewTransferFileManager) async -> NewUploadSession? {
        @InjectService var injection: SwissTransferInjection

        var transformedRecipients = [String]()
        if transferType == .mail {
            transformedRecipients = recipientsEmail.map { "\"" + $0 + "\"" }
        }

        var authorTrimmedEmail = ""
        var authorEmailToken: String?
        if transferType == .mail {
            authorTrimmedEmail = authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            authorEmailToken = try? await injection.emailTokensManager.getTokenForEmail(email: authorTrimmedEmail)
        }

        guard let filesToUpload = try? newTransferFileManager.filesToUpload(),
              filesToUpload.isEmpty == false else {
            return nil
        }

        let newUploadSession = NewUploadSession(
            duration: validityPeriod,
            authorEmail: authorTrimmedEmail,
            authorEmailToken: authorEmailToken,
            password: password,
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            numberOfDownload: downloadLimit,
            language: emailLanguage,
            recipientsEmails: Set(transformedRecipients),
            files: filesToUpload
        )

        return newUploadSession
    }

    public func restoreWith(uploadSession: any UploadSession) {
        authorEmail = uploadSession.authorEmail
        recipientsEmail = OrderedSet(uploadSession.recipientsEmails.map { String($0.dropFirst().dropLast()) })

        if !recipientsEmail.isEmpty || !authorEmail.isEmpty {
            transferType = .mail
        }

        password = uploadSession.password
        message = uploadSession.message
        validityPeriod = uploadSession.duration
        downloadLimit = uploadSession.numberOfDownload
        emailLanguage = uploadSession.language
    }
}
