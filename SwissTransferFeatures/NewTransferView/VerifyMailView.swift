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

import SwiftUI
import SwissTransferCoreUI

struct VerifyMailView: View {
    let mail: String
    let fakeCode = "123456"

    @State private var codeFieldStyle = SecurityCodeFieldStyle.normal

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Vérifie ton mail")
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)

            Text("On a envoyé un code à \(mail). Saisie le ci-dessous pour faire vérifier ton adresse mail dans l'app: ")
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)

            SecurityCodeTextField(style: $codeFieldStyle) { code in
                if code == fakeCode {
                    // Code valide
                } else {
                    withAnimation {
                        codeFieldStyle = .error
                    }
                }
            }

            Text("Pense à vérifier le dossier spam de ton adresse mail.")
                .font(.ST.caption)
                .foregroundStyle(Color.ST.textSecondary)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .stNavigationBarNewTransfer()
        .stNavigationBarStyle()
        .padding(16)
    }
}

#Preview {
    VerifyMailView(mail: "john.smith@ik.me")
}
