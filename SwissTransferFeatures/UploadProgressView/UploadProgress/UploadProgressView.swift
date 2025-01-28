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
import OSLog
import STCore
import STNetwork
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct UploadProgressView: View {
    @LazyInjectService private var injection: SwissTransferInjection
    @LazyInjectService private var notificationsHelper: NotificationsHelper

    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var viewModel: RootTransferViewModel
    @EnvironmentObject private var newTransferFileManager: NewTransferFileManager

    @StateObject private var transferSessionManager = TransferSessionManager()

    @State private var uploadProgressAd = UploadProgressAd.getRandomElement()

    @State private var currentUploadSession: SendableUploadSession?

    private var status: ProgressStatus {
        guard currentUploadSession != nil else {
            return .initializing
        }

        return .uploading(
            completedBytes: transferSessionManager.completedBytes,
            totalBytes: transferSessionManager.totalBytes
        )
    }

    private let localSessionUUID: String

    public init(localSessionUUID: String) {
        self.localSessionUUID = localSessionUUID
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: IKPadding.medium) {
                UploadProgressHeaderView(subtitle: uploadProgressAd.description)
                    .frame(maxWidth: IllustrationAndTextView.Style.emptyState.textMaxWidth)

                uploadProgressAd.image
                    .imageThatFits()
                    .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, value: .medium)
            .padding(.top, value: .large)
            .scrollableEmptyState()
            .background(Color.ST.background)
            .safeAreaButtons(spacing: IKPadding.huge) {
                UploadProgressIndicationView(status: status)

                Button(CoreUILocalizable.buttonCancel, action: cancelTransfer)
                    .buttonStyle(.ikBorderedProminent)
            }
            .stIconNavigationBar()
            .navigationBarBackButtonHidden()
            .task(startUpload)
            .sceneLifecycle(
                willEnterForeground: nil,
                didEnterBackground: notificationsHelper.sendBackgroundUploadNotificationForUploadSession
            )
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    @Sendable private func startUpload() async {
        do {
            Task { @MainActor in
                await notificationsHelper.requestPermissionIfNeeded()
            }

            let uploadManager = injection.uploadManager

            if viewModel.initializedFromShare,
               let uploadSessionFromShare = try? await uploadManager.getUploads().first(where: { $0.uuid == localSessionUUID }) {
                viewModel.restoreWith(uploadSession: uploadSessionFromShare)
            }

            let uploadSession = try await uploadManager.createRemoteUploadSession(localSessionUUID: localSessionUUID)

            await saveEmailTokenIfNeeded(uploadSession: uploadSession)

            currentUploadSession = uploadSession

            let transferUUID = try await transferSessionManager.uploadFiles(for: uploadSession)

            rootTransferViewState.transition(to: .success(transferUUID))
        } catch UploadManager.DomainError.deviceCheckFailed {
            rootTransferViewState.transition(to: .error(.deviceInvalidError))
        } catch let error as NSError where error.kotlinException is STNContainerErrorsException.EmailValidationRequired {
            guard let newUploadSession = await viewModel.toNewUploadSessionWith(newTransferFileManager) else {
                return
            }
            rootTransferViewState.transition(to: .verifyMail(newUploadSession))
        } catch {
            guard (error as NSError).code != NSURLErrorCancelled else { return }

            Logger.general.error("Error trying to start upload: \(error)")
            rootTransferViewState.transition(to: .error(nil))
        }
    }

    private func saveEmailTokenIfNeeded(uploadSession: SendableUploadSession) async {
        guard !uploadSession.authorEmail.isEmpty,
              let authorEmailToken = uploadSession.authorEmailToken else { return }

        try? await injection.emailTokensManager.setEmailToken(email: uploadSession.authorEmail, emailToken: authorEmailToken)
    }

    private func cancelTransfer() {
        guard let currentUploadSessionUUID = currentUploadSession?.uuid else { return }
        rootTransferViewState.cancelUploadUUID = CurrentUploadContainer(uuid: currentUploadSessionUUID)
    }
}

#Preview {
    UploadProgressView(localSessionUUID: "")
        .environmentObject(RootTransferViewModel())
}
