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
import STNetwork
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct UploadProgressView: View {
    @EnvironmentObject private var transferManager: TransferManager

    @StateObject private var transferSessionManager = TransferSessionManager()

    @State private var uploadProgressAd = UploadProgressAd.getRandomElement()
    @State private var successfulTransfer: TransferUi?
    @State private var error: Error?

    private let transferType: TransferType
    private let uploadSession: NewUploadSession
    private let dismiss: () -> Void

    public init(transferType: TransferType, uploadSession: NewUploadSession, dismiss: @escaping () -> Void) {
        self.transferType = transferType
        self.uploadSession = uploadSession
        self.dismiss = dismiss
    }

    public var body: some View {
        VStack(spacing: IKPadding.medium) {
            UploadProgressHeaderView(subtitle: uploadProgressAd.description)
                .frame(maxWidth: LargeEmptyStateView.textMaxWidth)

            uploadProgressAd.image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: LargeEmptyStateView.imageMaxWidth, maxHeight: .infinity)
        }
        .padding(.horizontal, value: .medium)
        .padding(.top, value: .large)
        .scrollableEmptyState()
        .safeAreaButtons(spacing: 32) {
            UploadProgressIndicationView(
                completedBytes: transferSessionManager.completedBytes,
                totalBytes: transferSessionManager.totalBytes
            )

            Button(STResourcesStrings.Localizable.buttonCancel, action: cancelTransfer)
                .buttonStyle(.ikBorderedProminent)
        }
        .stIconNavigationBar()
        .navigationBarBackButtonHidden()
        .task(startUpload)
    }

    @Sendable private func startUpload() async {
        do {
            let transferUUID = try await transferSessionManager.startUpload(session: uploadSession)

            // FIXME: Remove next two lines waiting for virus check
            try await Task.sleep(for: .seconds(2))
            try await transferManager.addTransferByLinkUUID(linkUUID: transferUUID)

            guard let transfer = transferManager.getTransferByUUID(transferUUID: transferUUID) else {
                fatalError("Couldn't find transfer")
            }
            successfulTransfer = transfer
        } catch {
            self.error = error
        }
    }

    private func cancelTransfer() {
        // TODO: Cancel Transfer
    }
}

#Preview {
    UploadProgressView(
        transferType: .qrcode,
        uploadSession: NewUploadSession(
            duration: "30",
            authorEmail: "",
            password: "",
            message: "Coucou",
            numberOfDownload: 250,
            language: .english,
            recipientsEmails: [],
            files: []
        )
    ) {}
}
