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
import STResources
import SwiftUI
import SwissTransferCoreUI

public struct VerifyMailView: View {
    @EnvironmentObject private var transferManager: TransferManager

    let mail: String

    @State private var codeFieldStyle = SecurityCodeFieldStyle.normal

    public init(mail: String) {
        self.mail = mail
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: IKPadding.large) {
                Text(STResourcesStrings.Localizable.validateMailTitle)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)

                Text(STResourcesStrings.Localizable.validateMailDescription(mail))
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
                let verifyEmailCodeBody = STNVerifyEmailCodeBody(code: code, email: mail)
                let token = try await STNUploadRepository().verifyEmailCode(verifyEmailCodeBody: verifyEmailCodeBody).token
            } catch {}

            codeFieldStyle = .normal
        }
    }
}

#Preview {
    VerifyMailView(mail: "john.smith@ik.me")
}
