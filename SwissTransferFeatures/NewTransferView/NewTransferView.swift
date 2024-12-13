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
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct NewTransferView: View {
    @LazyInjectService var injection: SwissTransferInjection

    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var viewModel: RootTransferViewModel
    @EnvironmentObject private var newTransferManager: NewTransferFileManager

    @State private var isLoadingFileToUpload = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: IKPadding.medium) {
                    NewTransferFilesCellView()
                        .padding(.horizontal, value: .medium)

                    NewTransferDetailsView(
                        authorEmail: $viewModel.authorEmail,
                        recipientEmail: $viewModel.recipientEmail,
                        message: $viewModel.message,
                        transferType: viewModel.transferType
                    )
                    .padding(.horizontal, value: .medium)

                    NewTransferTypeView(transferType: $viewModel.transferType)

                    NewTransferSettingsView(
                        duration: $viewModel.validityPeriod,
                        limit: $viewModel.downloadLimit,
                        language: $viewModel.emailLanguage,
                        password: $viewModel.password
                    )
                    .padding(.horizontal, value: .medium)
                }
                .padding(.vertical, value: .medium)
            }
            .background(Color.ST.background)
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
            .navigationDestination(for: DisplayableFile.self) { file in
                FileListView(parentFolder: file)
            }
            .navigationDestination(for: DisplayableRootFolder.self) { _ in
                FileListView(parentFolder: nil)
            }
        }
        .environmentObject(newTransferManager)
    }

    private func startUpload() {
        Task {
            isLoadingFileToUpload = true

            let recipientsEmail = [String]()
            if viewModel.transferType == .mail,
               viewModel.recipientEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                viewModel.recipientEmail.append(viewModel.recipientEmail.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            var authorTrimmedEmail = ""
            if viewModel.transferType == .mail {
                authorTrimmedEmail = viewModel.authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            do {
                let filesToUpload = try newTransferManager.filesToUpload()
                let newUploadSession = NewUploadSession(
                    duration: viewModel.validityPeriod,
                    authorEmail: authorTrimmedEmail,
                    password: viewModel.password,
                    message: viewModel.message.trimmingCharacters(in: .whitespacesAndNewlines),
                    numberOfDownload: viewModel.downloadLimit,
                    language: viewModel.emailLanguage,
                    recipientsEmails: recipientsEmail,
                    files: filesToUpload
                )

                viewModel.newUploadSession = newUploadSession

                let uploadSession = try? await injection.uploadManager
                    .createAndInitSendableUploadSession(newUploadSession: newUploadSession)

                guard let uploadSession else {
                    rootTransferViewState.transition(to: .error)
                    return
                }

                rootTransferViewState.transition(to: .uploadProgress(uploadSession))
            } catch {
                Logger.general.error("Error getting files to upload \(error.localizedDescription)")
            }

            isLoadingFileToUpload = false
        }
    }
}

#Preview {
    NewTransferView()
        .environmentObject(RootTransferViewState())
        .environmentObject(RootTransferViewModel())
        .environmentObject(NewTransferFileManager())
}
