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

import STCore
import SwiftUI

public protocol SettingSelectable: CaseIterable, Hashable {
    var title: String { get }
    var leftImage: Image? { get }
    var matomoName: MatomoName { get }
    static var matomoCategoryLocal: MatomoCategory? { get }
    static var matomoCategoryGlobal: MatomoCategory? { get }

    /// Call this function on a conforming type to serialise a setting
    func setSelected() async
}
