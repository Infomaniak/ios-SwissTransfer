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

public enum FileTypeIconSize {
    case small
    case big

    var size: CGFloat {
        switch self {
        case .small:
            return 16
        case .big:
            return 32
        }
    }

    var padding: CGFloat {
        switch self {
        case .small:
            return 8
        case .big:
            return 16
        }
    }

    var background: Color {
        switch self {
        case .small:
            return STResourcesAsset.Colors.greyPolarBear.swiftUIColor
        case .big:
            return .white
        }
    }
}

public struct FileTypeIcon: View {
    private let icon: Image
    private let type: FileTypeIconSize

    public init(icon: Image, type: FileTypeIconSize) {
        self.icon = icon
        self.type = type
    }

    public var body: some View {
        icon
            .resizable()
            .frame(width: type.size, height: type.size)
            .padding(type.padding)
            .background(
                type.background
                    .clipShape(Circle())
            )
    }
}

#Preview {
    VStack {
        FileTypeIcon(icon: STResourcesAsset.Images.fileAdobe.swiftUIImage, type: .small)
        FileTypeIcon(icon: STResourcesAsset.Images.fileAdobe.swiftUIImage, type: .big)
    }
    .background(.blue)
}
