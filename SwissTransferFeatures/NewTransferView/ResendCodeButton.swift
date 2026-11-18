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

import InfomaniakDI
import OSLog
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

struct ResendCodeButton: View {
    @EnvironmentObject private var mainViewState: MainViewState

    @State private var isSendingCode = false

    @Binding private var error: UserFacingError?

    private let emailValidation: EmailValidation?

    private var codeExpirationDate: Date? {
        guard let expirationTimestamp = emailValidation?.lastSentCodeExpirationTimestampSeconds?.int64Value else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(expirationTimestamp))
    }

    init(emailValidation: EmailValidation?, error: Binding<UserFacingError?>) {
        self.emailValidation = emailValidation
        _error = error
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let timeLeftSeconds = timeLeftSeconds(at: context.date)
            Button(action: resendCode) {
                Text(timeLeftSeconds <= 0 ?
                    STResourcesStrings.Localizable.validateMailResendCode :
                    STResourcesStrings.Localizable.validateMailResendCodeTemplate(timeLeftSeconds))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: timeLeftSeconds)
            }
            .buttonStyle(.ikBorderless)
            .ikButtonLoading(isSendingCode)
            .disabled(emailValidation == nil || timeLeftSeconds > 0)
        }
    }

    private func timeLeftSeconds(at date: Date) -> Int {
        guard let codeExpirationDate else { return 0 }
        return max(0, Int(codeExpirationDate.timeIntervalSince(date).rounded(.up)))
    }

    private func resendCode() {
        guard !isSendingCode, let validationId = emailValidation?.id else { return }
        isSendingCode = true

        Task {
            do {
                _ = try await mainViewState.swissTransferManager.uploadV2Manager.resendValidationEmail(
                    validationId: validationId
                )
            } catch {
                Logger.general.error("Error while resending validation email: \(error)")
                self.error = UserFacingError.unknownError
            }

            isSendingCode = false
        }
    }
}

#Preview {
    ResendCodeButton(
        emailValidation: EmailValidation(
            email: "test@mail.com",
            id: "",
            lastSentCodeExpirationTimestampSeconds: KotlinLong(value: Int64(Date.now.timeIntervalSince1970) + 5)
        ),
        error: .constant(nil)
    )
}
