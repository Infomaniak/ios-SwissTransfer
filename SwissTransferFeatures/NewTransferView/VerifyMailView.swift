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
import InfomaniakDI
import OSLog
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

private extension UserFacingError {
    static let validateMailCodeIncorrect = UserFacingError(errorDescription:
        STResourcesStrings.Localizable.validateMailCodeIncorrectError)
    static let validateMailUnknownError = UserFacingError(errorDescription:
        STResourcesStrings.Localizable.validateMailUnknownError)
    static let networkUnavailable = UserFacingError(errorDescription:
        STResourcesStrings.Localizable.networkUnavailable)
}

public struct VerifyMailView: View {
    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var mainViewState: MainViewState
    @EnvironmentObject private var rootTransferViewState: RootTransferViewState

    @State private var isVerifyingCode = false
    @State private var hasStartedUpload = false
    @State private var emailValidation: EmailValidation?
    @State private var error: UserFacingError?

    let localSessionUUID: String
    let authorEmail: String

    public init(localSessionUUID: String, authorEmail: String) {
        self.localSessionUUID = localSessionUUID
        self.authorEmail = authorEmail
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: IKPadding.large) {
                Text(STResourcesStrings.Localizable.validateMailTitle)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)

                Text(STResourcesStrings.Localizable.validateMailDescription(authorEmail))
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)

                SecurityCodeTextField(error: $error, completion: verifyCode)
                    .disabled(isVerifyingCode)
                    .opacity(isVerifyingCode ? 0.5 : 1)
                    .overlay {
                        if isVerifyingCode {
                            ProgressView()
                                .controlSize(.large)
                        }
                    }

                Text(STResourcesStrings.Localizable.validateMailInfo)
                    .font(.ST.caption)
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(STResourcesStrings.Localizable.contentDescriptionButtonBack, systemImage: "chevron.backward") {
                        rootTransferViewState.transition(to: .newTransfer)
                    }
                }
            }
            .stNavigationBarStyle()
            .padding(value: .medium)
            .safeAreaButtons {
                if let error {
                    Text(error.errorDescription)
                        .font(.ST.caption)
                        .foregroundStyle(Color.ST.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(STResourcesStrings.Localizable.buttonOpenMailApp, action: openMailApp)
                    .buttonStyle(.ikBorderedProminent)
                    .disabled(isVerifyingCode)

                ResendCodeButton(emailValidation: emailValidation, error: $error)
                    .disabled(isVerifyingCode)
            }
            .appBackground()
            .task(observeEmailValidation)
        }
        .matomoView(view: .verifyMail)
    }

    @Sendable private func observeEmailValidation() async {
        let emailValidationFlow = mainViewState.swissTransferManager.uploadV2Manager.emailValidationStatus(email: authorEmail)
        for await emailValidation in emailValidationFlow {
            guard !Task.isCancelled else { return }
            self.emailValidation = emailValidation

            if let emailValidation, emailValidation.lastSentCodeExpirationTimestampSeconds == nil {
                startUpload()
            }
        }
    }

    private func openMailApp() {
        guard let openMailURL = URL(string: "message:") else { return }
        openURL(openMailURL)
    }

    private func startUpload() {
        guard !hasStartedUpload else { return }
        hasStartedUpload = true
        rootTransferViewState.transition(to: .uploadProgress(localSessionUUID: localSessionUUID))
    }

    private func verifyCode(_ code: String) {
        guard !isVerifyingCode else { return }
        isVerifyingCode = true

        Task {
            do {
                try await mainViewState.swissTransferManager.uploadV2Manager.validateEmailWithCode(
                    email: authorEmail,
                    code: code
                )

                startUpload()
            } catch let error as NSError where error.kotlinException is STNEmailValidationException.InvalidCode
                || error.kotlinException is STNEmailValidationException.CodeExpired {
                withAnimation {
                    self.error = UserFacingError.validateMailCodeIncorrect
                }
            } catch let error as NSError where error.kotlinException is STNNetworkException {
                withAnimation {
                    self.error = UserFacingError.networkUnavailable
                }
            } catch {
                Logger.general.error("Error while validating email code: \(error)")
                withAnimation {
                    self.error = UserFacingError.validateMailUnknownError
                }
            }

            isVerifyingCode = false
        }
    }
}

#Preview {
    VerifyMailView(localSessionUUID: "", authorEmail: "test@ik.me")
}
