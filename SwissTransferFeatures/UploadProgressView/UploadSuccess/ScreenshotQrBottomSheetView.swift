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
import STResources
import SwiftUI
import SwissTransferCoreUI

struct ScreenshotQrBottomSheetView: View {
    @Environment(\.dismiss) private var dismiss

    private let quickSharingDescription = STResourcesStrings.Localizable.quickSharingDescription
    private let shareStringParameter = STResourcesStrings.Localizable.buttonShare
    private let copyLinkStringParameter = STResourcesStrings.Localizable.buttonCopyLink

    private var description: AttributedString {
        var result = AttributedString(quickSharingDescription(shareStringParameter, copyLinkStringParameter))
        result.font = .ST.body

        if let argumentRange = result.range(of: shareStringParameter) {
            result[argumentRange].font = .ST.headline
            result[argumentRange].foregroundColor = .ST.textPrimary
        }

        if let argumentRange = result.range(of: copyLinkStringParameter) {
            result[argumentRange].font = .ST.headline
            result[argumentRange].foregroundColor = .ST.textPrimary
        }

        return result
    }

    var body: some View {
        EmptyStateFloatingPanelView(
            image: STResourcesAsset.Images.bulb.swiftUIImage,
            title: STResourcesStrings.Localizable.oneClickSharing,
            subtitle: description
        ) {
            Button(STResourcesStrings.Localizable.understandTitleButton) {
                dismiss()
            }
            .buttonStyle(.ikBorderedProminent)
        }
        .matomoView(view: "ScreenshotQrCodeView")
    }
}

#Preview {
    ScreenshotQrBottomSheetView()
}
