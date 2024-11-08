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

                    NewTransferDetailsView()
                        .padding(.horizontal, value: .medium)

                    NewTransferTypeView()

                    NewTransferSettingsView()
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
            .navigationDestination(for: NewUploadSession.self) { newUploadSession in
                RootUploadProgressView(transferType: .qrCode, uploadSession: newUploadSession, dismiss: dismiss.callAsFunction)
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
        .environment(\.dismissModal) {
            dismiss()
        }
        .environmentObject(newTransferManager)
    }

    func startUpload() {
        Task {
            isLoadingFileToUpload = true

            do {
                let filesToUpload = try newTransferManager.filesToUpload()
                let newUploadSession = NewUploadSession(
                    duration: ValidityPeriod.thirty,
                    authorEmail: "",
                    password: "",
                    message: "",
                    numberOfDownload: DownloadLimit.twoHundredFifty,
                    language: .english,
                    recipientsEmails: [],
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
