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

import SwiftUI
import STResources

struct FirstTransferButton: View {
    let style: NewTransferStyle
    let action: () -> Void

    private var angle: Angle {
        switch style {
        case .small:
            return Angle(degrees: -30)
        case .big:
            return .zero
        }
    }

    private var offset: CGSize {
        switch style {
        case .small:
            return CGSize(width: 0, height: -15)
        case .big:
            return CGSize(width: 0, height: -35)
        }
    }

    private var width: CGFloat {
        switch style {
        case .small:
            return 28
        case .big:
            return 36
        }
    }

    private var height: CGFloat {
        switch style {
        case .small:
            return 34
        case .big:
            return 44
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing, spacing: -5) {
                if style == .small {
                    Text("Fais ton premier transfert !")
                        .font(.bodyRegular)
                        .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)
                }
                STResourcesAsset.Images.arrow.swiftUIImage
                    .resizable()
                    .frame(width: width, height: height)
                    .rotationEffect(angle)
            }
            .offset(offset)
            NewTransferButton(style: style, action: action)
        }
    }
}

#Preview {
    VStack {
        FirstTransferButton(style: .small) {}
        FirstTransferButton(style: .big) {}
    }
}
