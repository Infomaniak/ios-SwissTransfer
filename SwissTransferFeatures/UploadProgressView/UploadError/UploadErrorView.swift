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
import InfomaniakCoreUIResources
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

public struct UploadErrorView: View {
    @EnvironmentObject private var mainViewState: MainViewState
    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var rootTransferViewModel: RootTransferViewModel
    @EnvironmentObject private var newTransferFileManager: NewTransferFileManager

    @State private var isRetryingUpload = false

    private let uploadError: UploadError

    public init(uploadError: UploadError) {
        self.uploadError = uploadError
    }

    public var body: some View {
        NavigationStack {
            IllustrationAndTextView(
                image: uploadError.image,
                title: uploadError.title,
                subtitle: uploadError.subtitle,
                style: .emptyState
            )
            .padding(value: .medium)
            .scrollableEmptyState()
            .appBackground()
            .safeAreaButtons {
                if uploadError.canRetry {
                    Button(CoreUILocalizable.buttonRetry, action: retryTransfer)
                        .buttonStyle(.ikBorderedProminent)
                        .ikButtonLoading(isRetryingUpload)
                }
                Button(STResourcesStrings.Localizable.buttonEditTransfer, action: editTransfer)
                    .buttonStyle(.ikBorderless)
            }
            .navigationBarBackButtonHidden()
            .stIconNavigationBar()
        }
        .matomoView(view: .uploadError)
    }

    private func retryTransfer() {
        Task {
            isRetryingUpload = true
            guard let newUploadSession = await rootTransferViewModel.toNewUploadSessionWith(
                newTransferFileManager,
                swissTransferManager: mainViewState.swissTransferManager
            ) else {
                isRetryingUpload = false
                return
            }

            let localUploadSession = try await mainViewState.swissTransferManager.uploadManager
                .createAndGetSendableUploadSession(newUploadSession: newUploadSession)

            rootTransferViewState.transition(to: .uploadProgress(localSessionUUID: localUploadSession.uuid))
            isRetryingUpload = false
        }
    }

    private func editTransfer() {
        rootTransferViewState.transition(to: .newTransfer)
    }
}

#Preview {
    UploadErrorView(uploadError: .default)
        .environmentObject(RootTransferViewState())
        .environmentObject(RootTransferViewModel())
}
