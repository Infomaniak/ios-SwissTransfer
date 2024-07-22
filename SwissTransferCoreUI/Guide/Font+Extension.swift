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

import Foundation
import SwiftUI

public extension Font {
    static let header1 = system(size: 22).weight(.semibold)
    static let header2 = system(size: 18).weight(.semibold)
    static let bodyRegular = system(size: 16).weight(.regular)
    static let bodyMedium = system(size: 16).weight(.medium)
    static let bodySmallRegular = system(size: 14).weight(.regular)
    static let bodySmallMedium = system(size: 14).weight(.medium)
    static let labelRegular = system(size: 12).weight(.regular)
    static let labelMedium = system(size: 12).weight(.medium)

    // MARK: - Specific Font

    static let specificMedium = system(size: 22).weight(.medium)
    static let specificLight = system(size: 22).weight(.light)
}
