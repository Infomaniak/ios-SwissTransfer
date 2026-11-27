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

public enum NewTransferConstants: Sendable {
    public static let minPasswordLength = 6
    public static let maxPasswordLength = 25

    public static let maxFileSize = STCore.FileUtils().MAX_FILES_SIZE
    public static let maxFileCount = Int(STCore.FileUtils().MAX_FILE_COUNT)
}

@MainActor
public final class RootTransferViewModel: ObservableObject {
    @Published public var transferType = TransferType.defaultChoice
    @Published public var authorEmail = ""
    @Published public var recipientsEmail = OrderedSet<String>()
    @Published public var message = ""
    @Published public var title = ""
    @Published public var password = ""
    @Published public var validityPeriod: ValidityPeriod?
    @Published public var downloadLimit = DownloadLimit.twoHundredFifty
    @Published public var emailLanguage = EmailLanguage.french
    @Published public var files = [TransferableFile]()
    @Published public var emailText = ""
    @Published public var selectedOrganizationId: Int64?

    public private(set) var initializedFromShare: Bool

    public func isTransferConfigurationValid(isGuest: Bool) -> Bool {
        if !password.isEmpty,
           password.count < NewTransferConstants.minPasswordLength || password.count > NewTransferConstants.maxPasswordLength {
            return false
        }

        if isAuthorEmailRequired(isGuest: isGuest) {
            let trimmedAuthorEmail = authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedAuthorEmail.isEmpty || !EmailChecker(email: trimmedAuthorEmail).validate() {
                return false
            }
        }

        if transferType == .mail {
            let trimmedEmailText = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
            if recipientsEmail.isEmpty && !EmailChecker(email: trimmedEmailText).validate() {
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
        Task {
            @InjectService var settingsManager: AppSettingsManager
            guard let appSettings = try await settingsManager.getAppSettings() else { return }

            authorEmail = appSettings.lastAuthorEmail ?? ""
            transferType = appSettings.lastTransferType
            downloadLimit = appSettings.downloadLimit
            emailLanguage = appSettings.emailLanguage
        }
    }

    public func isAuthorEmailRequired(isGuest: Bool) -> Bool {
        return isGuest || transferType == .mail
    }

    public func toUploadSessionRequest(_ newTransferFileManager: NewTransferFileManager,
                                       isGuest: Bool) -> UploadSessionRequest? {
        guard let validityPeriod else { return nil }

        guard let filesToUpload = try? newTransferFileManager.filesToUpload(),
              !filesToUpload.isEmpty else {
            return nil
        }

        let authorTrimmedEmail = isAuthorEmailRequired(isGuest: isGuest)
            ? authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            : ""
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        let filesMetadata = filesToUpload.map {
            FileToUploadMetadata(name: $0.name, size: $0.size, mimeType: $0.mimeType, localPath: $0.localPath)
        }

        return UploadSessionRequest(
            validityPeriod: validityPeriod,
            authorEmail: authorTrimmedEmail,
            password: password,
            title: trimmedTitle.isEmpty ? nil : trimmedTitle,
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            sizeOfUpload: filesToUpload.reduce(0) { $0 + $1.size },
            downloadCountLimit: downloadLimit,
            filesCount: Int32(filesToUpload.count),
            languageCode: emailLanguage,
            filesMetadata: filesMetadata,
            recipientsEmails: Set(recipientsEmail),
            organizationAccountId: selectedOrganizationId.map { KotlinLong(value: $0) }
        )
    }

    public func restoreWith(state: RootTransferRestorableState) {
        authorEmail = state.authorEmail
        title = state.title
        recipientsEmail = state.recipientsEmail
        transferType = state.transferType
        password = state.password
        message = state.message
        validityPeriod = state.validityPeriod
        downloadLimit = state.downloadLimit
        emailLanguage = state.emailLanguage
        selectedOrganizationId = state.organizationAccountId
    }
}
