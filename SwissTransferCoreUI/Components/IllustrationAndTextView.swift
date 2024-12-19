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

public extension IllustrationAndTextView {
    enum Style {
        case emptyState
        case bottomSheet

        public var textMaxWidth: CGFloat? {
            switch self {
            case .emptyState:
                return 300
            case .bottomSheet:
                return nil
            }
        }
    }
}

public struct IllustrationAndTextView: View {
    let image: Image?
    let title: String
    let subtitle: String?
    let style: Style

    public init(image: Image?, title: String, subtitle: String? = nil, style: Style) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.style = style
    }

    public var body: some View {
        VStack(spacing: 32) {
            if let image {
                image.imageThatFits()
            }
            VStack(spacing: IKPadding.medium) {
                Text(title)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textSecondary)
                }
            }
            .frame(maxWidth: style.textMaxWidth)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    IllustrationAndTextView(
        image: STResourcesAsset.Images.beers.swiftUIImage,
        title: "Empty State Title",
        subtitle: "Consequat magna cupidatat aute fugiat quis dolore ea labore nisi velit. Culpa deserunt adipisicing velit consequat.",
        style: .emptyState
    )
}
