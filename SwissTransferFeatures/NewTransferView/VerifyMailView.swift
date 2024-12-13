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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct VerifyMailView: View {
    @LazyInjectService var injection: SwissTransferInjection

    @EnvironmentObject private var transferManager: TransferManager
    @EnvironmentObject private var rootTransferViewState: RootTransferViewState

    let newUploadSession: NewUploadSession

    @State private var codeFieldStyle = SecurityCodeFieldStyle.normal

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

                SecurityCodeTextField(style: $codeFieldStyle) { code in
                    verifyCode(code)
                }

                Text(STResourcesStrings.Localizable.validateMailInfo)
                    .font(.ST.caption)
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .stNavigationBarNewTransfer()
            .stNavigationBarStyle()
            .padding(value: .medium)
        }
    }

    func verifyCode(_ code: String) {
        guard codeFieldStyle != .loading else { return }
        codeFieldStyle = .loading

        Task {
            do {
                let verifyEmailCodeBody = STNVerifyEmailCodeBody(code: code, email: newUploadSession.authorEmail)
                let token = try await STNUploadRepository().verifyEmailCode(verifyEmailCodeBody: verifyEmailCodeBody).token

                let uploadSessionWithEmailToken = NewUploadSession(
                    duration: newUploadSession.duration,
                    authorEmail: newUploadSession.authorEmail,
                    authorEmailToken: token,
                    password: newUploadSession.password,
                    message: newUploadSession.message,
                    numberOfDownload: newUploadSession.numberOfDownload,
                    language: newUploadSession.language,
                    recipientsEmails: newUploadSession.recipientsEmails,
                    files: newUploadSession.files
                )

                let uploadSession = try await injection.uploadManager
                    .createUploadSession(newUploadSession: uploadSessionWithEmailToken)

                try await injection.emailTokensManager.setEmailToken(email: newUploadSession.authorEmail, token: token)

                withAnimation {
                    rootTransferViewState.transition(to: .uploadProgress(uploadSession))
                }
            } catch {
                rootTransferViewState.transition(to: .error)
            }

            codeFieldStyle = .normal
        }
    }
}

#Preview {
    VerifyMailView(newUploadSession: PreviewHelper.sampleNewUploadSession)
}
