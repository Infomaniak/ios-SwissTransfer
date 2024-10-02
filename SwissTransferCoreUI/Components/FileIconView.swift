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

import InfomaniakCoreSwiftUI
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
            return IKPadding.small
        case .big:
            return IKPadding.medium
        }
    }

    var background: Color {
        switch self {
        case .small:
            return .ST.cardBackground
        case .big:
            return .ST.background
        }
    }

    var shouldScale: Bool {
        switch self {
        case .small:
            return true
        case .big:
            return false
        }
    }
}

public struct FileIconView: View {
    private let icon: Image
    private let type: FileTypeIconSize

    @ScaledMetric private var scaledSize: CGFloat
    @ScaledMetric private var scaledPadding: CGFloat

    private var size: CGFloat {
        type.shouldScale ? scaledSize : type.size
    }

    private var padding: CGFloat {
        type.shouldScale ? scaledPadding : type.padding
    }

    public init(icon: Image, type: FileTypeIconSize) {
        self.icon = icon
        self.type = type

        _scaledSize = ScaledMetric(wrappedValue: type.size, relativeTo: .body)
        _scaledPadding = ScaledMetric(wrappedValue: type.padding, relativeTo: .body)
    }

    public var body: some View {
        icon
            .resizable()
            .frame(width: size, height: size)
            .padding(padding)
            .background(
                type.background
                    .clipShape(Circle())
            )
    }
}

#Preview {
    VStack {
        FileIconView(icon: STResourcesAsset.Images.fileAdobe.swiftUIImage, type: .small)
        FileIconView(icon: STResourcesAsset.Images.fileAdobe.swiftUIImage, type: .big)
            .padding()
            .background {
                Color.ST.cardBackground
            }
    }
}
