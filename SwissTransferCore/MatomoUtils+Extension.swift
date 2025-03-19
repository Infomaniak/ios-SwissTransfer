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
import InfomaniakDI
import SwiftUI

public extension MatomoUtils {
    static let siteID = "24"
    static let siteURL = URL(string: "https://analytics.infomaniak.com/matomo.php")!
}

// MARK: - Views and Categories

public extension MatomoUtils.EventCategory {
    static let transferType = MatomoUtils.EventCategory(displayName: "transferType")
}

// MARK: - Track views

struct MatomoView: ViewModifier {
    @LazyInjectService var matomo: MatomoUtils

    let path: [String]

    init(path: [String]) {
        self.path = path
    }

    init(view: String) {
        path = [view]
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                matomo.track(view: path)
            }
    }
}

public extension View {
    func matomoView(path: [String]) -> some View {
        modifier(MatomoView(path: path))
    }

    func matomoView(view: String) -> some View {
        modifier(MatomoView(view: view))
    }
}
