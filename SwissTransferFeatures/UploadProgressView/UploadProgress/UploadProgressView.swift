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
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakCoreUIResources
import InfomaniakDI
import OSLog
import Sentry
import STCore
import STNetwork
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct UploadProgressView: View {
    @LazyInjectService private var injection: SwissTransferInjection
    @LazyInjectService private var notificationsHelper: NotificationsHelper
    @LazyInjectService private var thumbnailProvider: ThumbnailProvidable

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
            fractionCompleted: transferSessionManager.fractionCompleted,
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
            .onChange(of: transferSessionManager.transferResult) { transferResult in
                guard let transferResult else { return }
                switch transferResult {
                case .success(let transferUUID):
                    uploadFinished(transferUUID: transferUUID)
                case .failure(let error):
                    handleUploadError(error)
                }
            }
        }
        .matomoView(view: "UploadProgressView")
    }

    @Sendable private func startUpload() async {
        await catchingUploadErrors {
            Task { @MainActor in
                await notificationsHelper.requestPermissionIfNeeded()
            }

            reportTransferToMatomo()

            let uploadManager = injection.uploadManager

            if viewModel.initializedFromShare,
               let uploadSessionFromShare = try? await uploadManager.getUploads().first(where: { $0.uuid == localSessionUUID }) {
                viewModel.restoreWith(uploadSession: uploadSessionFromShare)
            }

            let uploadSession = try await uploadManager.createRemoteUploadSession(localSessionUUID: localSessionUUID)

            await saveEmailTokenIfNeeded(uploadSession: uploadSession)

            currentUploadSession = uploadSession

            try await transferSessionManager.uploadFiles(for: uploadSession)
        }
    }

    private func uploadFinished(transferUUID: String) {
        rootTransferViewState.transition(to: .success(transferUUID))
    }

    private func catchingUploadErrors(_ task: () async throws -> Void) async {
        do {
            try await task()
        } catch let error as STDeviceCheckError {
            sendErrorToSentryIfNeeded(error: error.underlyingError)
            rootTransferViewState.transition(to: .error(.appIntegrity))
        } catch let error as NSError where error.kotlinException is STNContainerErrorsException.DailyQuotaExceededException {
            sendErrorToSentryIfNeeded(error: error)
            rootTransferViewState.transition(to: .error(.dailyQuotaExceeded))
        } catch let error as NSError where error.kotlinException is STNContainerErrorsException.EmailValidationRequired {
            guard let newUploadSession = await viewModel.toNewUploadSessionWith(newTransferFileManager) else {
                return
            }

            sendErrorToSentryIfNeeded(error: error)
            rootTransferViewState.transition(to: .verifyMail(newUploadSession))
        } catch let error as NSError where error.kotlinException is STNContainerErrorsException.DomainBlockedException {
            sendErrorToSentryIfNeeded(error: error)
            rootTransferViewState.transition(to: .error(.restrictedLocation))
        } catch {
            guard (error as NSError).code != NSURLErrorCancelled else { return }

            sendErrorToSentryIfNeeded(error: error)
            Logger.general.error("Error trying to start upload: \(error)")
            rootTransferViewState.transition(to: .error(.default))
        }
    }

    private func handleUploadError(_ error: NSError) {
        Task {
            await catchingUploadErrors {
                throw error
            }
        }
    }

    private func sendErrorToSentryIfNeeded(error: Error) {
        guard ![NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut].contains((error as NSError).code) else {
            return
        }

        SentrySDK.capture(error: error) { scope in
            if let containerError = (error as NSError).kotlinException as? STNContainerErrorsException {
                scope.setContext(value: ["requestId": containerError.requestContextId], key: "Container Error")
            }
        }
    }

    private func saveEmailTokenIfNeeded(uploadSession: SendableUploadSession) async {
        guard !uploadSession.authorEmail.isEmpty,
              let authorEmailToken = uploadSession.authorEmailToken else { return }

        try? await injection.uploadTokensManager.setEmailToken(email: uploadSession.authorEmail, emailToken: authorEmailToken)
    }

    private func cancelTransfer() {
        guard let currentUploadSessionUUID = currentUploadSession?.uuid else { return }
        rootTransferViewState.cancelUploadContainer = CurrentUploadContainer(
            uuid: currentUploadSessionUUID,
            uploadsCancellable: transferSessionManager
        )
    }

    private func reportTransferToMatomo() {
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: .newTransferData, action: .data, name: viewModel.transferType.matomoValue)
    }
}

#Preview {
    UploadProgressView(localSessionUUID: "")
        .environmentObject(RootTransferViewModel())
}
