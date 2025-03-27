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
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

private extension UserFacingError {
    static let validateMailCodeIncorrect = UserFacingError(errorDescription:
        STResourcesStrings.Localizable.validateMailCodeIncorrectError)
}

public struct VerifyMailView: View {
    @LazyInjectService private var injection: SwissTransferInjection

    @Environment(\.openURL) private var openURL

    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var viewModel: RootTransferViewModel

    @State private var isVerifyingCode = false
    @State private var error: UserFacingError?

    let newUploadSession: NewUploadSession

    public init(newUploadSession: NewUploadSession) {
        self.newUploadSession = newUploadSession
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: IKPadding.large) {
                Text(STResourcesStrings.Localizable.validateMailTitle)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)

                Text(STResourcesStrings.Localizable.validateMailDescription(newUploadSession.authorEmail))
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

                ResendCodeButton(emailToVerify: newUploadSession.authorEmail, resendTimeDelaySeconds: 30, error: $error)
                    .disabled(isVerifyingCode)
            }
        }
        .matomoView(view: "VerifyMailView")
    }

    private func openMailApp() {
        guard let openMailURL = URL(string: "message:") else { return }
        openURL(openMailURL)
    }

    private func verifyCode(_ code: String) {
        guard !isVerifyingCode else { return }
        isVerifyingCode = true

        Task {
            do {
                let addressToVerify = newUploadSession.authorEmail
                let token = try await injection.uploadManager.verifyEmailCode(code: code, address: addressToVerify).token

                let uploadSessionWithEmailToken = NewUploadSession(
                    duration: newUploadSession.duration,
                    authorEmail: addressToVerify,
                    authorEmailToken: token,
                    password: newUploadSession.password,
                    message: newUploadSession.message,
                    numberOfDownload: newUploadSession.numberOfDownload,
                    language: newUploadSession.language,
                    recipientsEmails: newUploadSession.recipientsEmails,
                    files: newUploadSession.files
                )

                viewModel.authorEmailToken = token

                let localUploadSession = try await injection.uploadManager
                    .createAndGetSendableUploadSession(newUploadSession: uploadSessionWithEmailToken)

                rootTransferViewState.transition(to: .uploadProgress(localSessionUUID: localUploadSession.uuid))
            } catch let error as NSError where error.kotlinException is STNEmailValidationException.InvalidPasswordException {
                withAnimation {
                    self.error = UserFacingError.validateMailCodeIncorrect
                }
            } catch UploadManager.DomainError.dailyQuotaExceeded {
                rootTransferViewState.transition(to: .error(.dailyQuotaExceeded))
            } catch {
                rootTransferViewState.transition(to: .error(.default))
            }

            isVerifyingCode = false
        }
    }
}

#Preview {
    VerifyMailView(newUploadSession: PreviewHelper.sampleNewUploadSession)
}
