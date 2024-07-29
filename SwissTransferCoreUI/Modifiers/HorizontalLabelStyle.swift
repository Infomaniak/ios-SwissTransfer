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

public struct HorizontalLabelStyle: LabelStyle {
    private let spacing: CGFloat
    private let font: Font
    private let fontColor: Color
    private let iconColor: Color

    public init(
        spacing: Double = 8.0,
        font: Font = .ST.callout,
        fontColor: Color = STResourcesAsset.Colors.greyOrca.swiftUIColor,
        iconColor: Color = STResourcesAsset.Colors.greenMain.swiftUIColor
    ) {
        self.spacing = spacing
        self.font = font
        self.fontColor = fontColor
        self.iconColor = iconColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
                .foregroundStyle(iconColor)
            configuration.title
        }
        .font(font)
        .foregroundStyle(fontColor)
    }
}

public extension LabelStyle where Self == HorizontalLabelStyle {
    static var horizontal: HorizontalLabelStyle { .init() }
}
