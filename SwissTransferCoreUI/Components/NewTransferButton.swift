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
import SwissTransferCore

public enum NewTransferStyle {
    case big
    case small

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
    @Binding var selection: [ImportedItem]

    private let style: NewTransferStyle

    init(selection: Binding<[ImportedItem]>, style: NewTransferStyle = .small) {
        _selection = selection
        self.style = style
    }

    var body: some View {
        AddFilesMenu(selection: $selection) {
            STResourcesAsset.Images.plus.swiftUIImage
                .accessibilityLabel(STResourcesStrings.Localizable.contentDescriptionCreateNewTransferButton)
        }
        .buttonStyle(.ikFloatingActionButton(customSize: style.buttonSize))
    }
}

public struct SidebarNewTransferButton: View {
    @Binding var selection: [ImportedItem]

    public init(selection: Binding<[ImportedItem]>) {
        _selection = selection
    }

    public var body: some View {
        AddFilesMenu(selection: $selection) {
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

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selection = [ImportedItem]()

    VStack {
        NewTransferButton(selection: $selection, style: .small)
        NewTransferButton(selection: $selection, style: .big)

        SidebarNewTransferButton(selection: $selection)
    }
}
