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
import InfomaniakCoreSwiftUI
import STResources
import SwiftUI
import VersionChecker

public extension TemplateSharedStyle {
    static let swissTransfer = TemplateSharedStyle(
        background: STResourcesAsset.Colors.white.swiftUIColor,
        titleTextStyle: .init(font: .ST.title2, color: STResourcesAsset.Colors.greyOrca.swiftUIColor),
        descriptionTextStyle: .init(font: .body, color: STResourcesAsset.Colors.greyElephant.swiftUIColor),
        buttonStyle: .init(
            background: STResourcesAsset.Colors.greenMain.swiftUIColor,
            textStyle: .init(font: .headline, color: Color.white),
            height: IKButtonHeight.large,
            radius: 16
        )
    )
}
