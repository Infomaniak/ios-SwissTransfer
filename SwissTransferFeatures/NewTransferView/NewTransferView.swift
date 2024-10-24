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
import STCore
import STResources
import STUploadProgressView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct NewTransferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var newTransferManager: NewTransferManager

    public init(urls: [URL]) {
        let transferManager = NewTransferManager()
        _ = transferManager.addFiles(urls: urls)
        _newTransferManager = StateObject(wrappedValue: transferManager)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: IKPadding.medium) {
                    // FilesCell
                    NewTransferFilesCellView()
                        .padding(.horizontal, value: .medium)

                    // Title and message
                    NewTransferDetailsView()
                        .padding(.horizontal, value: .medium)

                    // Type
                    NewTransferTypeView()

                    // Settings
                    NewTransferSettingsView()
                        .padding(.horizontal, value: .medium)
                }
                .padding(.vertical, value: .medium)
            }
            .floatingContainer {
                NavigationLink {
                    UploadProgressView(uploadSession: NewUploadSession(
                        duration: "30",
                        authorEmail: "",
                        password: "",
                        message: "",
                        numberOfDownload: 250,
                        language: .english,
                        recipientsEmails: [],
                        files: newTransferManager.uploadFiles
                    ))
                } label: {
                    Text(STResourcesStrings.Localizable.buttonNext)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.ikBorderedProminent)
                .ikButtonFullWidth(true)
                .controlSize(.large)
            }
            .scrollDismissesKeyboard(.immediately)
            .stNavigationBarNewTransfer(title: STResourcesStrings.Localizable.importFilesScreenTitle)
            .stNavigationBarStyle()
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
}

#Preview {
    NewTransferView(urls: [])
}
