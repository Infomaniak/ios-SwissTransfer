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
import InfomaniakDeviceCheck
import InfomaniakDI
import OSLog
import STCore
import STNetwork
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct NewTransferView: View {
    @LazyInjectService private var injection: SwissTransferInjection

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var viewModel: RootTransferViewModel
    @EnvironmentObject private var newTransferFileManager: NewTransferFileManager

    @State private var rootNavigationPath = NavigationPath()
    @State private var isLoadingFileToUpload = false

    public init() {}

    public var body: some View {
        NavigationStack(path: $rootNavigationPath) {
            ScrollView {
                VStack(spacing: IKPadding.medium) {
                    NewTransferTypeView(transferType: $viewModel.transferType)

                    NavigationLink(value: TransferableRootFolder()) {
                        NewTransferFilesCellView(files: $viewModel.files)
                    }
                    .padding(.horizontal, value: .medium)

                    NewTransferDetailsView(
                        authorEmail: $viewModel.authorEmail,
                        recipientsEmail: $viewModel.recipientsEmail,
                        message: $viewModel.message,
                        transferType: viewModel.transferType
                    )
                    .padding(.horizontal, value: .medium)

                    NewTransferSettingsView(
                        duration: $viewModel.validityPeriod,
                        limit: $viewModel.downloadLimit,
                        language: $viewModel.emailLanguage,
                        password: $viewModel.password,
                        transferType: viewModel.transferType
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
                .ikButtonLoading(isLoadingFileToUpload || !newTransferFileManager.importedItems.isEmpty)
                .disabled(!viewModel.isNewTransferValid)
            }
            .scrollDismissesKeyboard(.immediately)
            .stNavigationBarFullScreen(title: STResourcesStrings.Localizable.importFilesScreenTitle)
            .stNavigationBarStyle()
            .navigationDestination(for: TransferableFile.self) { file in
                FileListView(parentFolder: file)
            }
            .navigationDestination(for: TransferableRootFolder.self) { _ in
                FileListView(parentFolder: nil)
            }
            .navigationDestination(for: NewUploadSession.self) { newUploadSession in
                VerifyMailView(newUploadSession: newUploadSession)
            }
        }
        .environment(\.dismissModal) { dismiss() }
    }

    private func startUpload() {
        Task {
            isLoadingFileToUpload = true

            var transformedRecipients = [String]()
            if viewModel.transferType == .mail {
                transformedRecipients = viewModel.recipientsEmail.map { "\"" + $0 + "\"" }
            }

            var authorTrimmedEmail = ""
            var authorEmailToken: String?
            if viewModel.transferType == .mail {
                authorTrimmedEmail = viewModel.authorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                authorEmailToken = try? await injection.emailTokensManager.getTokenForEmail(email: authorTrimmedEmail)
            }

            guard let filesToUpload = try? newTransferFileManager.filesToUpload() else {
                return
            }

            let newUploadSession = NewUploadSession(
                duration: viewModel.validityPeriod,
                authorEmail: authorTrimmedEmail,
                authorEmailToken: authorEmailToken,
                password: viewModel.password,
                message: viewModel.message.trimmingCharacters(in: .whitespacesAndNewlines),
                numberOfDownload: viewModel.downloadLimit,
                language: viewModel.emailLanguage,
                recipientsEmails: Set(transformedRecipients),
                files: filesToUpload
            )

            viewModel.newUploadSession = newUploadSession

            withAnimation {
                rootTransferViewState.transition(to: .uploadProgress)
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
