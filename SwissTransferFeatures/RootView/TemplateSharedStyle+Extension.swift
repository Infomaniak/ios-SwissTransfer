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

import DesignSystem
import InfomaniakCoreSwiftUI
import SwiftUI
import VersionChecker

public extension TemplateSharedStyle {
    static let swissTransfer = TemplateSharedStyle(
        background: .ST.background,
        titleTextStyle: .init(font: .ST.title2, color: .ST.textPrimary),
        descriptionTextStyle: .init(font: .ST.body, color: .ST.textSecondary),
        buttonStyle: .init(
            background: .ST.primary,
            textStyle: .init(font: .ST.headline, color: .ST.onPrimary),
            height: IKButtonHeight.large,
            radius: IKRadius.large
        )
    )
}
