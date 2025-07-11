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

import InfomaniakCoreCommonUI
import STResources
import SwiftUI
import SwissTransferCore

public struct FirstTransferButton: View {
    @Binding var selection: [ImportedItem]

    private let style: NewTransferStyle
    private let matomoCategory: MatomoUtils.EventCategory

    private var offset: CGSize {
        switch style {
        case .small:
            return CGSize(width: 0, height: -15)
        case .big:
            return CGSize(width: -70, height: -35)
        }
    }

    public init(selection: Binding<[ImportedItem]>, style: NewTransferStyle, matomoCategory: MatomoUtils.EventCategory) {
        _selection = selection
        self.style = style
        self.matomoCategory = matomoCategory
    }

    public var body: some View {
        if style == .small {
            HStack(spacing: 10) {
                VStack(alignment: .trailing, spacing: -5) {
                    Text(STResourcesStrings.Localizable.firstTransferDescription)
                        .font(.ST.body)
                        .foregroundStyle(Color.ST.textSecondary)

                    STResourcesAsset.Images.arrow.swiftUIImage
                        .resizable()
                        .frame(width: 28, height: 34)
                        .rotationEffect(Angle(degrees: -30))
                }
                .offset(offset)

                NewTransferButton(selection: $selection, style: style, matomoCategory: matomoCategory)
            }
        } else {
            ZStack {
                NewTransferButton(selection: $selection, style: style, matomoCategory: matomoCategory)

                STResourcesAsset.Images.arrow.swiftUIImage
                    .resizable()
                    .frame(width: 36, height: 44)
                    .offset(offset)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selection = [ImportedItem]()
    VStack {
        FirstTransferButton(selection: $selection, style: .small, matomoCategory: .importFileFromSent)
        FirstTransferButton(selection: $selection, style: .big, matomoCategory: .importFileFromSent)
    }
}
