/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct DeepLinkPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var password = ""
    @FocusState private var isFocused: Bool

    let url: IdentifiableURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: IKPadding.large) {
                    Text("!Saisi le mot de passe qui ta été fourni pour télécharger ces fichiers.")
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textSecondary)

                    TogglableSecureTextField(password: $password)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            checkPassword()
                        }

                    Button("!Valider") {
                        checkPassword()
                    }
                    .buttonStyle(.ikBorderedProminent)
                    .ikButtonFullWidth(true)
                    .controlSize(.large)
                }
                .padding(value: .medium)
            }
            .onAppear {
                isFocused = true
            }
            .stNavigationBarStyle()
            .stNavigationTitle("!Ce transfert est sécurisé")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("!Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func checkPassword() {

    }
}

#Preview {
    DeepLinkPasswordView(url: IdentifiableURL(url: URL(string: "https://swisstransfer.infomaniak.com")!))
}
