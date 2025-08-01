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

import DesignSystem
import InfomaniakCoreSwiftUI
import InfomaniakCoreUIResources
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
    @LazyInjectService private var accountManager: SwissTransferCore.AccountManager

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.shareExtensionContext) private var shareExtensionContext

    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var viewModel: RootTransferViewModel
    @EnvironmentObject private var newTransferFileManager: NewTransferFileManager

    @State private var rootNavigationPath = NavigationPath()
    @State private var isLoadingFileToUpload = false
    @State private var importFilesTasks = [Task<Void, Never>]()

    private var isNewTransferValid: Bool {
        viewModel.isNewTransferValid && newTransferFileManager.isNewTransferValid
    }

    public init() {}

    public var body: some View {
        NavigationStack(path: $rootNavigationPath) {
            ScrollView {
                VStack(spacing: IKPadding.medium) {
                    NewTransferTypeView(transferType: $viewModel.transferType)
                        .padding(.horizontal, value: .medium)

                    NavigationLink(value: TransferableRootFolder()) {
                        NewTransferFilesCellView(files: $viewModel.files, importFilesTasks: $importFilesTasks)
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
                    Text(CoreUILocalizable.buttonNext)
                }
                .buttonStyle(.ikBorderedProminent)
                .ikButtonLoading(isLoadingFileToUpload || !newTransferFileManager.importedItems.isEmpty)
                .disabled(!isNewTransferValid)
            }
            .scrollDismissesKeyboard(.immediately)
            .stNavigationBarFullScreen(title: STResourcesStrings.Localizable.importFilesScreenTitle)
            .stNavigationBarStyle()
            .navigationDestination(for: TransferableFile.self) { file in
                FileListView(parentFolder: file, matomoCategory: .newTransfer)
            }
            .navigationDestination(for: TransferableRootFolder.self) { _ in
                FileListView(parentFolder: nil, matomoCategory: .newTransfer)
            }
            .navigationDestination(for: NewUploadSession.self) { newUploadSession in
                VerifyMailView(newUploadSession: newUploadSession)
            }
        }
        .environment(\.dismissModal) {
            if let shareExtensionContext {
                shareExtensionContext.dismissShareSheet()
            } else {
                dismiss()
            }
            cancelTasks()
        }
        .matomoView(view: .newTransfer)
    }

    private func startUpload() {
        Task {
            isLoadingFileToUpload = true

            // We need to ensure that we have an account initialized before starting
            _ = await accountManager.getCurrentManager()

            guard let newUploadSession = await viewModel.toNewUploadSessionWith(newTransferFileManager) else { return }

            let localUploadSession = try await injection.uploadManager
                .createAndGetSendableUploadSession(newUploadSession: newUploadSession)

            if let shareExtensionContext {
                let importURL = try injection.sharedApiUrlCreator
                    .importFromShareExtensionURL(localImportUUID: localUploadSession.uuid)
                openURL(importURL)
                shareExtensionContext.dismissShareSheet()
            } else {
                rootTransferViewState.transition(to: .uploadProgress(localSessionUUID: localUploadSession.uuid))
            }

            isLoadingFileToUpload = false
        }
    }

    private func cancelTasks() {
        for task in importFilesTasks {
            task.cancel()
        }
    }
}

#Preview {
    NewTransferView()
        .environmentObject(RootTransferViewState())
        .environmentObject(RootTransferViewModel())
        .environmentObject(NewTransferFileManager())
}
