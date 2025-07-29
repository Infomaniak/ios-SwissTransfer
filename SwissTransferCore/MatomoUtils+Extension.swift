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

import Foundation
import InfomaniakCoreCommonUI
import STCore
import SwiftUI

public extension MatomoUtils {
    static let siteID = "24"
    static let siteURL = URL(string: "https://analytics.infomaniak.com/matomo.php")!

    func track(eventWithCategory category: MatomoCategory, action: UserAction = .click, name: MatomoName, value: Float? = nil) {
        track(eventWithCategory: category.value, action: action, name: name.value, value: value)
    }
}

// MARK: - Track views

public extension View {
    func matomoView(view: MatomoScreen) -> some View {
        modifier(MatomoView(view: [view.value]))
    }
}
