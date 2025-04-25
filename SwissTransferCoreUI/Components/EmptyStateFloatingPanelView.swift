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

import DesignSystem
import STResources
import SwiftUI

public struct EmptyStateFloatingPanelView<Buttons: View>: View {
    let image: Image
    let title: String
    let attributedSubtitle: AttributedString?
    let buttons: () -> Buttons

    public init(
        image: Image,
        title: String,
        attributedSubtitle: AttributedString? = nil,
        @ViewBuilder buttons: @escaping () -> Buttons
    ) {
        self.image = image
        self.title = title
        self.attributedSubtitle = attributedSubtitle
        self.buttons = buttons
    }

    public init(
        image: Image,
        title: String,
        attributedSubtitle: String?,
        @ViewBuilder buttons: @escaping () -> Buttons
    ) {
        self.image = image
        self.title = title
        self.attributedSubtitle = AttributedString(attributedSubtitle ?? "")
        self.buttons = buttons
    }

    public var body: some View {
        VStack(spacing: IKPadding.huge) {
            IllustrationAndTextView(
                image: image,
                title: title,
                attributedSubtitle: attributedSubtitle ?? "",
                style: .bottomSheet
            )
            BottomButtonsView(buttons: buttons)
        }
    }
}

#Preview {
    EmptyStateFloatingPanelView(
        image: STResourcesAsset.Images.paperPlanesCrossOctagon.swiftUIImage,
        title: STResourcesStrings.Localizable.uploadCancelConfirmBottomSheetTitle,
        attributedSubtitle: ""
    ) {
        Button(STResourcesStrings.Localizable.buttonCloseAndContinue) {}
            .buttonStyle(.ikBorderedProminent)
    }
    .border(.red)
}
