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

struct UploadProgressView: View {
    @Environment(\.dismissModal) private var dismissModal
    @EnvironmentObject private var transferManager: TransferManager

    @StateObject private var transferSessionManager = TransferSessionManager()

    @State private var uploadProgressAd = UploadProgressAd.getRandomElement()

    @Binding var transferUUID: String?
    @Binding var error: Error?

    let transferType: TransferType
    let uploadSession: NewUploadSession

    private let emptyStateStyle = IllustrationAndTextView.Style.largeEmptyState

    var body: some View {
        VStack(spacing: IKPadding.medium) {
            UploadProgressHeaderView(subtitle: uploadProgressAd.description)
                .frame(maxWidth: emptyStateStyle.textMaxWidth)

            uploadProgressAd.image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: emptyStateStyle.imageMaxWidth)
        }
        .padding(.horizontal, value: .medium)
        .padding(.top, value: .large)
        .scrollableEmptyState()
        .background(Color.ST.background)
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
            withAnimation {
                self.transferUUID = transferUUID
            }
        } catch {
            withAnimation {
                self.error = error
            }
        }
    }

    private func cancelTransfer() {
        // TODO: Cancel Transfer
        dismissModal()
    }
}

#Preview {
    UploadProgressView(
        transferUUID: .constant(nil),
        error: .constant(nil),
        transferType: .qrCode,
        uploadSession: PreviewHelper.sampleNewUploadSession
    )
}
