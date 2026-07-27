/*
 Infomaniak Core UI - iOS
 Copyright (C) 2026 Infomaniak Network SA

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

public struct OrganizationInitialsView: View {
    let initials: String
    let backgroundColor: Color
    let foregroundColor: Color
    let size: CGFloat

    public init(initials: String, backgroundColor: Color, foregroundColor: Color, size: CGFloat) {
        self.initials = initials
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.size = size
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: IKRadius.small)
                .fill(backgroundColor)
            Text(initials)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(foregroundColor)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    OrganizationInitialsView(initials: "TE", backgroundColor: .red, foregroundColor: .white, size: 40)
}
