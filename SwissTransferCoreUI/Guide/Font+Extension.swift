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

import SwiftUI

public extension Font {
    /// List of fonts used by the SwissTransfer app.
    enum ST {
        // MARK: - Base

        /// Figma name: *Titre H1*
        public static let title = Font.dynamicTypeSizeFont(size: 22, weight: .semibold, relativeTo: .title)
        /// Figma name: *Titre H2*
        public static let title2 = Font.dynamicTypeSizeFont(size: 18, weight: .semibold, relativeTo: .title2)
        /// Figma name: *Body Medium*
        public static let headline = Font.dynamicTypeSizeFont(size: 16, weight: .medium, relativeTo: .headline)
        /// Figma name: *Body Regular*
        public static let body = Font.dynamicTypeSizeFont(size: 16, weight: .regular, relativeTo: .body)
        /// Figma name: *Body Small Regular*
        public static let callout = Font.dynamicTypeSizeFont(size: 14, weight: .regular, relativeTo: .callout)
        /// Figma name: *Body Small Medium*
        public static let calloutMedium = Font.dynamicTypeSizeFont(size: 14, weight: .medium, relativeTo: .callout)
        /// Figma name: *Label Regular*
        public static let caption = Font.dynamicTypeSizeFont(size: 12, weight: .regular, relativeTo: .caption)

        // MARK: - Specific Font

        /// Figma name: *Spécifique 32 Medium*
        public static let specificLargeTitleMedium = Font.dynamicTypeSizeFont(size: 32, weight: .medium, relativeTo: .largeTitle)
        /// Figma name: *Spécifique 22 Medium*
        public static let specificTitleMedium = Font.dynamicTypeSizeFont(size: 22, weight: .medium, relativeTo: .title)
        /// Figma name: *Spécifique 22 Light*
        public static let specificTitleLight = Font.dynamicTypeSizeFont(size: 22, weight: .light, relativeTo: .title)
        /// Figma name: *Spécifique 18 Light*
        public static let specificTitle2Light = Font.dynamicTypeSizeFont(size: 18, weight: .light, relativeTo: .title2)
    }

    /// Create a custom font with the UIFont preferred font family.
    /// - Parameters:
    ///   - size: Default size of the font for the "large" `Dynamic Type Size`.
    ///   - weight: Weight of the font.
    ///   - textStyle: The text style on which the font will be based to scale.
    ///
    /// - Returns: A font with the specified attributes.
    ///
    /// SwiftUI will use the default system font with the specified weight and size use `Dynamic Type Size`.
    private static func dynamicTypeSizeFont(size: CGFloat, weight: Weight, relativeTo textStyle: TextStyle) -> Font {
        let fontFamily = UIFont.preferredFont(forTextStyle: .body).familyName
        return custom(fontFamily, size: size, relativeTo: textStyle).weight(weight)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        Text("BASE")
            .font(.title3)
            .foregroundStyle(Color.gray)

        Text("Title")
            .font(.ST.title)
        Text("Title 2")
            .font(.ST.title2)
        Text("Headline")
            .font(.ST.headline)
        Text("Body")
            .font(.ST.body)
        Text("Callout")
            .font(.ST.callout)
        Text("Callout Medium")
            .font(.ST.calloutMedium)
        Text("Caption")
            .font(.ST.caption)

        Divider()

        Text("SPECIFIC")
            .font(.title3)
            .foregroundStyle(Color.gray)

        Text("Specific Large Title Medium")
            .font(.ST.specificLargeTitleMedium)
        Text("Specific Title Medium")
            .font(.ST.specificTitleMedium)
        Text("Specific Title Light")
            .font(.ST.specificTitleLight)
        Text("Specific Title 2 Light")
            .font(.ST.specificTitle2Light)
    }
    .padding()
}
