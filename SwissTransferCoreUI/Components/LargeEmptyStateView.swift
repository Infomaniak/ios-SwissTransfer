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

public struct LargeEmptyStateView: View {
    let image: Image
    let title: String
    let subtitle: String
    let imageHorizontalPadding: CGFloat?

    public init(image: Image, title: String, subtitle: String, imageHorizontalPadding: CGFloat? = IKPadding.medium) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageHorizontalPadding = imageHorizontalPadding
    }

    public var body: some View {
        VStack(spacing: 32) {
            image
                .resizable()
                .scaledToFit()
                .padding(.horizontal, imageHorizontalPadding ?? 0)
                .frame(maxWidth: 400)

            VStack(spacing: IKPadding.medium) {
                Text(title)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)

                Text(subtitle)
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)
                    .frame(maxWidth: 300)
            }
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    LargeEmptyStateView(
        image: STResourcesAsset.Images.beersHands.swiftUIImage,
        title: "Empty State Title",
        subtitle: "Consequat magna cupidatat aute fugiat quis dolore ea labore nisi velit. Culpa deserunt adipisicing velit consequat.",
        imageHorizontalPadding: 0
    )
}
