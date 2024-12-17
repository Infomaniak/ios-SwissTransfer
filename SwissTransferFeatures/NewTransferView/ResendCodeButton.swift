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
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

struct ResendCodeButton: View {
    @LazyInjectService private var injection: SwissTransferInjection

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isSendingCode = false
    @State private var timeLeftSeconds: Int

    @Binding private var error: UserFacingError?

    private let emailToVerify: String
    private let resendTimeDelaySeconds: Int

    private var isSendCodeDelayDone: Bool {
        return timeLeftSeconds <= 0
    }

    init(emailToVerify: String, resendTimeDelaySeconds: Int, error: Binding<UserFacingError?>) {
        self.emailToVerify = emailToVerify
        self.resendTimeDelaySeconds = resendTimeDelaySeconds
        _timeLeftSeconds = State(initialValue: resendTimeDelaySeconds)
        _error = error
    }

    var body: some View {
        Button(action: resendCode) {
            HStack {
                Text(isSendCodeDelayDone ?
                    STResourcesStrings.Localizable.validateMailResendCode :
                    STResourcesStrings.Localizable.validateMailResendCodeTemplate(timeLeftSeconds))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .onReceive(timer) { _ in
                        withAnimation {
                            timeLeftSeconds -= 1
                            if isSendCodeDelayDone {
                                timer.upstream.connect().cancel()
                            }
                        }
                    }
            }
        }
        .buttonStyle(.ikBorderless)
        .ikButtonLoading(isSendingCode)
        .disabled(!isSendCodeDelayDone)
    }

    private func resendCode() {
        guard !isSendingCode else { return }
        isSendingCode = true

        Task {
            do {
                try await injection.uploadManager.resendEmailCode(address: emailToVerify)
                timeLeftSeconds = resendTimeDelaySeconds
                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            } catch {
                self.error = UserFacingError.unknownError
            }

            isSendingCode = false
        }
    }
}

#Preview {
    ResendCodeButton(emailToVerify: "test@mail.com", resendTimeDelaySeconds: 5, error: .constant(nil))
}
