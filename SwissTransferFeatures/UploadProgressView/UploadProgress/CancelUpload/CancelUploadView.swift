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

import STResources
import SwiftUI
import SwissTransferCoreUI
import InfomaniakDI
import STCore

public struct CancelUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var rootTransferViewState: RootTransferViewState

    private let uploadSessionUUID: String

    public init(uploadSessionUUID: String) {
        self.uploadSessionUUID = uploadSessionUUID
    }

    public var body: some View {
        EmptyStateFloatingPanelView(
            image: STResourcesAsset.Images.paperPlanesCrossOctagon.swiftUIImage,
            title: STResourcesStrings.Localizable.uploadCancelConfirmBottomSheetTitle
        ) {
            Button(role: .destructive, action: cancelUpload) {
                Text(STResourcesStrings.Localizable.buttonCancelTransfer)
            }
            .buttonStyle(.ikBorderedProminent)

            Button(STResourcesStrings.Localizable.buttonCloseAndContinue) {
                dismiss()
            }
            .buttonStyle(.ikBorderless)
        }
    }

    private func cancelUpload() {
        dismiss()
        withAnimation {
            rootTransferViewState.state = .newTransfer
        }

        Task {
            @InjectService var injection: SwissTransferInjection
            let uploadManager = injection.uploadManager
            try? await uploadManager.cancelUploadSession(uuid: uploadSessionUUID)
        }
    }
}

#Preview {
    CancelUploadView(uploadSessionUUID: "")
}
