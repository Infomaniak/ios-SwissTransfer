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

public enum NewTransferStyle {
    case big
    case small

    var size: CGFloat {
        switch self {
        case .big:
            return 24
        case .small:
            return 16
        }
    }

    var buttonSize: CGFloat {
        switch self {
        case .big:
            return 80
        case .small:
            return 56
        }
    }
}

struct NewTransferButton: View {
    var style: NewTransferStyle = .small
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            STResourcesAsset.Images.plus.swiftUIImage
                .resizable()
                .tint(.white)
                .frame(width: style.size, height: style.size)
                .frame(width: style.buttonSize, height: style.buttonSize)
                .background {
                    RoundedRectangle(cornerRadius: style.size)
                }
                .accessibilityLabel(STResourcesStrings.Localizable.contentDescriptionCreateNewTransferButton)
        }
    }
}

public struct SidebarNewTransferButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Label {
                Text(STResourcesStrings.Localizable.contentDescriptionCreateNewTransferButton)
            } icon: {
                STResourcesAsset.Images.plus.swiftUIImage
            }
        }
        .buttonStyle(.ikBorderedProminent)
        .ikButtonFullWidth(true)
        .controlSize(.large)
    }
}

#Preview {
    VStack {
        NewTransferButton(style: .small) {}
        NewTransferButton(style: .big) {}
    }
}
