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
import InfomaniakCoreUIResources
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

public struct UploadErrorView: View {
    @LazyInjectService var injection: SwissTransferInjection

    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var rootTransferViewModel: RootTransferViewModel

    private let userFacingError: UserFacingError?

    private var errorSubtitle: String {
        guard let userFacingError else {
            return STResourcesStrings.Localizable.uploadErrorDescription
        }

        return userFacingError.errorDescription
    }

    public init(userFacingError: UserFacingError?) {
        self.userFacingError = userFacingError
    }

    public var body: some View {
        NavigationStack {
            IllustrationAndTextView(
                image: STResourcesAsset.Images.ghostMagnifyingGlassQuestionMark.swiftUIImage,
                title: STResourcesStrings.Localizable.uploadErrorTitle,
                subtitle: errorSubtitle,
                style: .emptyState
            )
            .padding(value: .medium)
            .scrollableEmptyState()
            .appBackground()
            .safeAreaButtons {
                if rootTransferViewModel.newUploadSession != nil {
                    Button(CoreUILocalizable.buttonRetry, action: retryTransfer)
                        .buttonStyle(.ikBorderedProminent)
                }
                Button(STResourcesStrings.Localizable.buttonEditTransfer, action: editTransfer)
                    .buttonStyle(.ikBordered)
            }
            .navigationBarBackButtonHidden()
            .stIconNavigationBar()
        }
    }

    private func retryTransfer() {
        rootTransferViewState.transition(to: .uploadProgress)
    }

    private func editTransfer() {
        rootTransferViewState.transition(to: .newTransfer)
    }
}

#Preview {
    UploadErrorView(userFacingError: nil)
        .environmentObject(RootTransferViewState())
        .environmentObject(RootTransferViewModel())
}
