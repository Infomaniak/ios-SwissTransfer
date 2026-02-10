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
import SwissTransferCoreUI

extension View {
    func stTab(_ tab: STTab, avatarImage: UIImage? = nil) -> some View {
        modifier(STTabModifier(tab: tab, avatarImage: avatarImage))
    }
}

struct STTabModifier: ViewModifier {
    let tab: STTab
    let avatarImage: UIImage?

    func body(content: Content) -> some View {
        content
            .navigableTab(tab)
            .tabItem { tab.label(avatarImage: avatarImage) }
            .tag(tab)
    }
}
