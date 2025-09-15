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

import DesignSystem
import InfomaniakCoreSwiftUI
import InfomaniakCoreUIResources
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct DeepLinkPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var mainViewState: MainViewState

    @State private var password = ""
    @State private var error: InputErrorState?

    @FocusState private var isFocused: Bool

    private let url: IdentifiableURL

    private var isButtonDisabled: Bool {
        return password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public init(url: IdentifiableURL) {
        self.url = url
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: IKPadding.large) {
                    Text(STResourcesStrings.Localizable.deeplinkPasswordDescription)
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textSecondary)

                    TogglableSecureTextField(password: $password, error: error)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit(checkPassword)
                }
                .padding(value: .medium)
            }
            .safeAreaButtons {
                Button(STResourcesStrings.Localizable.buttonConfirm, action: checkPassword)
                    .buttonStyle(.ikBorderedProminent)
                    .disabled(isButtonDisabled)
            }
            .onAppear {
                isFocused = true
            }
            .stNavigationBarStyle()
            .stNavigationTitle(STResourcesStrings.Localizable.sharePasswordTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    ToolbarCloseButton(dismiss: dismiss)
                }
            }
        }
    }

    private func checkPassword() {
        Task {
            error = nil
            let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

            do {
                @InjectService var accountManager: SwissTransferCore.AccountManager
                guard let transferManager = await accountManager.getCurrentManager() else { return }

                guard let transferUUID = try await transferManager.addTransferByUrl(
                    url: url.url.path(),
                    password: trimmedPassword
                ) else { return }
                let transfer = try await transferManager.getTransferByUUID(transferUUID: transferUUID)

                dismiss()
                if let transfer {
                    mainViewState.selectedTransfer = .transfer(transfer)
                }
            } catch {
                let kotlinException = (error as NSError).kotlinException

                if let localizedError = kotlinException as? LocalizedError, let message = localizedError.errorDescription {
                    self.error = .errorWithMessage(message)
                } else {
                    self.error = .errorWithMessage(CoreUILocalizable.anErrorHasOccurred)
                }
                isFocused = true
            }
        }
    }
}

#Preview {
    DeepLinkPasswordView(url: IdentifiableURL(url: URL(string: "https://swisstransfer.infomaniak.com")!))
}
