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
import STResources
import SwiftUI
import SwissTransferCoreUI

struct UploadErrorView: View {
    var body: some View {
        IllustrationAndTextView(
            image: STResourcesAsset.Images.ghostMagnifyingGlassQuestionMark.swiftUIImage,
            title: STResourcesStrings.Localizable.uploadErrorTitle,
            subtitle: STResourcesStrings.Localizable.uploadErrorDescription,
            style: .emptyState
        )
        .padding(value: .medium)
        .scrollableEmptyState()
        .safeAreaButtons {
            Button(STResourcesStrings.Localizable.buttonRetry, action: retryTransfer)
                .buttonStyle(.ikBorderedProminent)
            Button(STResourcesStrings.Localizable.buttonEditTransfer, action: editTransfer)
                .buttonStyle(.ikBordered)
        }
        .navigationBarBackButtonHidden()
        .stIconNavigationBar()
    }

    private func retryTransfer() {}

    private func editTransfer() {}
}

#Preview {
    UploadErrorView()
}
