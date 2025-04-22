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

struct ScreenshotSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var description: AttributedString {
        var result = AttributedString(template(share, copyLink))
        result.font = .ST.specificTitle2Light

        if let argumentRange = result.range(of: share) {
            result[argumentRange].font = .ST.title2
        }

        if let argumentRange = result.range(of: copyLink) {
            result[argumentRange].font = .ST.title2
        }

        return result
    }

    let title = STResourcesStrings.Localizable.oneClickSharing
    let template = STResourcesStrings.Localizable.quickSharingDescription
    let share = STResourcesStrings.Localizable.buttonShare
    let copyLink = STResourcesStrings.Localizable.buttonCopyLink

    var body: some View {
        VStack(spacing: IKPadding.huge) {
            STResourcesAsset.Images.bulb.swiftUIImage

            Text(title)
                .font(Font.ST.headline)
                .foregroundColor(Color.ST.textPrimary)
                .multilineTextAlignment(.center)

            Text(description)
                .font(Font.ST.body)
                .foregroundColor(Color.ST.textSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: IKPadding.mini) {
                Button(STResourcesStrings.Localizable.understandTitleButton) {
                    dismiss()
                }
                .buttonStyle(.ikBorderedProminent)
            }
            .ikButtonFullWidth(true)
            .controlSize(.large)
        }
        .padding(.horizontal, value: .large)
        .padding(.top, value: .medium)
    }
}
