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

public final class RootTransferViewModel: ObservableObject {
    public static let minPasswordLength = 6
    public static let maxPasswordLength = 25

    @Published public var transferType = TransferType.qrCode
    @Published public var authorEmail = ""
    @Published public var recipientsEmail = OrderedSet<String>()
    @Published public var message = ""
    @Published public var password = ""
    @Published public var validityPeriod = ValidityPeriod.thirty
    @Published public var downloadLimit = DownloadLimit.twoHundredFifty
    @Published public var emailLanguage = EmailLanguage.french
    @Published public var files = [TransferableFile]()

    @Published public var newUploadSession: NewUploadSession?

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

    public init() {
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
}
