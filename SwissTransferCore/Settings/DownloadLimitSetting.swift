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

public enum DownloadLimitSetting: SettingSelectable {
    case limit1
    case limit20
    case limit100
    case limit250

    public var title: String {
        switch self {
        case .limit1:
            return "1"
        case .limit20:
            return "20"
        case .limit100:
            return "100"
        case .limit250:
            return "250"
        }
    }

    public var icon: Image? { nil }
}
