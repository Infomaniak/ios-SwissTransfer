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

struct STNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    STResourcesAsset.Images.logo.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }
            }
            .stNavigationBarStyle()
    }
}

public extension View {
    /// The navigationBar with correct styling and SwissTransfer logo in the center
    func stNavigationBar() -> some View {
        modifier(STNavigationBarModifier())
    }
}
