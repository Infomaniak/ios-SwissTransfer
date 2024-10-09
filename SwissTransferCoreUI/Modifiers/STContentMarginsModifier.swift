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

private extension Edge.Set {
    var verticalEdge: VerticalEdge? {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        default:
            return nil
        }
    }
}

public extension View {
    func stContentMargins(_ edge: Edge.Set, value: CGFloat, safeAreaValue: CGFloat? = nil) -> some View {
        modifier(STContentMarginsModifier(edge: edge, value: value, safeAreaValue: safeAreaValue))
    }
}

public struct STContentMarginsModifier: ViewModifier {
    let edge: Edge.Set
    let value: CGFloat
    let safeAreaValue: CGFloat?

    public func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .contentMargins(edge, value)
        } else {
            content
                .safeAreaInset(edge: edge.verticalEdge ?? .top) {
                    Color.clear.frame(height: safeAreaValue ?? value)
                }
        }
    }
}
