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

import InfomaniakCoreSwiftUI
import InfomaniakDI
import OSLog
import STCore
import STResources
import STUploadProgressView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct NewTransferView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var newTransferManager: NewTransferManager

    @State private var isLoadingFileToUpload = false
    @State private var navigationPath = NavigationPath()

    @State private var transferType = TransferType.qrCode
    @State private var authorEmail = ""
    @State private var recipientEmail = ""
    @State private var message = ""
    @State private var password = ""
    @State private var duration = ValidityPeriod.thirty
    @State private var downloadLimit = DownloadLimit.twoHundredFifty
    @State private var language = EmailLanguage.french

    public init(urls: [URL]) {
        let transferManager = NewTransferManager()
        _ = transferManager.addFiles(urls: urls)
        _newTransferManager = StateObject(wrappedValue: transferManager)
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: IKPadding.medium) {
                    NewTransferFilesCellView()
                        .padding(.horizontal, value: .medium)

                    NewTransferDetailsView(
                        authorEmail: $authorEmail,
                        recipientEmail: $recipientEmail,
                        message: $message,
                        transferType: transferType
                    )
                    .padding(.horizontal, value: .medium)

                    NewTransferTypeView(transferType: $transferType)

                    NewTransferSettingsView(duration: $duration, limit: $downloadLimit, language: $language, password: $password)
                        .padding(.horizontal, value: .medium)
                }
                .padding(.vertical, value: .medium)
            }
            .safeAreaButtons {
                Button(action: startUpload) {
                    Text(STResourcesStrings.Localizable.buttonNext)
                }
                .buttonStyle(.ikBorderedProminent)
                .ikButtonLoading(isLoadingFileToUpload)
            }
            .scrollDismissesKeyboard(.immediately)
            .stNavigationBarNewTransfer(title: STResourcesStrings.Localizable.importFilesScreenTitle)
            .stNavigationBarStyle()
            .navigationDestination(for: NewUploadSession.self) { uploadSession in
                RootUploadProgressView(transferType: transferType, uploadSession: uploadSession, dismiss: dismiss.callAsFunction)
            }
            .navigationDestination(for: DisplayableFile.self) { file in
                FileListView(parentFolder: file)
                    .stNavigationBarNewTransfer(title: file.name)
                    .stNavigationBarStyle()
            }
            .navigationDestination(for: DisplayableRootFolder.self) { _ in
                FileListView(parentFolder: nil)
                    .stNavigationBarNewTransfer(title: STResourcesStrings.Localizable.importFilesScreenTitle)
                    .stNavigationBarStyle()
            }
        }
        .onAppear(perform: initializeValuesFromSettings)
        .environment(\.dismissModal) {
            dismiss()
        }
        .environmentObject(newTransferManager)
    }

    private func initializeValuesFromSettings() {
        @InjectService var settingsManager: AppSettingsManager
        guard let appSettings = settingsManager.getAppSettings() else { return }

        transferType = appSettings.lastTransferType
        authorEmail = appSettings.lastAuthorEmail ?? ""

        duration = appSettings.validityPeriod
        downloadLimit = appSettings.downloadLimit
        language = appSettings.emailLanguage
    }

    private func startUpload() {
        Task {
            isLoadingFileToUpload = true

            let recipientsEmail = [String]()
            if transferType == .mail,
               recipientEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                recipientEmail.append(recipientEmail.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            var authorTrimmedEmail = ""
            if transferType == .mail {
                authorTrimmedEmail = authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            do {
                let filesToUpload = try newTransferManager.filesToUpload()
                let newUploadSession = NewUploadSession(
                    duration: duration,
                    authorEmail: authorTrimmedEmail,
                    password: password,
                    message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                    numberOfDownload: downloadLimit,
                    language: language,
                    recipientsEmails: recipientsEmail,
                    files: filesToUpload
                )
                navigationPath.append(newUploadSession)
            } catch {
                Logger.general.error("Error getting files to upload \(error.localizedDescription)")
            }

            isLoadingFileToUpload = false
        }
    }
}

#Preview {
    NewTransferView(urls: [])
}
