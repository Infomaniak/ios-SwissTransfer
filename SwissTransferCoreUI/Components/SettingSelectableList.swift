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

public struct SettingSelectableList<T: SettingSelectable>: View {
    @Environment(\.dismiss) private var dismiss

    let items: [T]
    let selected: T
    let onSelection: (T) -> Void

    public init(_ type: T.Type, selected: T, onSelection: @escaping (T) -> Void) {
        items = Array(type.allCases)
        self.selected = selected
        self.onSelection = onSelection
    }

    public var body: some View {
        ForEach(items, id: \.self) { item in
            VStack {
                HStack {
                    Label {
                        Text(item.title)
                            .font(.ST.body)
                            .foregroundStyle(Color.ST.textPrimary)
                    } icon: {
                        item.icon
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if selected == item {
                        STResourcesAsset.Images.check.swiftUIImage
                            .foregroundStyle(Color.ST.primary)
                    }
                }
                .padding(.vertical, value: .medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture {
                    onSelection(item)
                    dismiss()
                }

                if item != items.last {
                    DividerView()
                }
            }
            .padding(.horizontal, value: .medium)
        }
    }
}

#Preview {
    SettingSelectableList(ValiditySetting.self, selected: .day1) { _ in }
}
