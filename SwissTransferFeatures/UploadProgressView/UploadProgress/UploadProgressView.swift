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
        VStack {
            VStack(spacing: 32) {
                Text(STResourcesStrings.Localizable.uploadProgressTitle)
                    .font(.ST.headline)

                Text(uploadProgressAd.attributedString)
                    .font(.ST.title2)
                    .multilineTextAlignment(.center)
            }

            uploadProgressAd.image
                .resizable()
                .scaledToFit()
                .frame(maxHeight: .infinity)
        }
        .padding(.vertical, value: .medium)
        .padding(.top, value: .large)
        .safeAreaButtons(spacing: 32) {
            VStack(spacing: IKPadding.small) {
                Text(STResourcesStrings.Localizable.uploadProgressIndication)
                    .font(.ST.headline)

                ProgressView(value: transferSessionManager.percentCompleted)
            }

            Button(STResourcesStrings.Localizable.buttonCancel) {}
                .buttonStyle(.borderedProminent)
                .ikButtonFullWidth(true)
        }
        .stIconNavigationBar()
        .navigationBarBackButtonHidden()
        .task {
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
        .navigationDestination(for: TransferUi.self) { navigableTransfer in
            SuccessfulTransferView(type: transferType, dismiss: dismiss)
        }
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
