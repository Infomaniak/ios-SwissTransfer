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

import DesignSystem
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore

public struct SettingSelectableList<T: SettingSelectable>: View {
    @Environment(\.dismiss) private var dismiss

    let items: [T]
    let selected: T?
    let onSelection: (T) -> Void

    public init(
        _ type: T.Type,
        selected: T?,
        onSelection: @escaping (T) -> Void
    ) {
        items = Array(type.allCases)
        self.selected = selected
        self.onSelection = onSelection
    }

    public var body: some View {
        VStack(spacing: 0) {
            if T.self == ValidityPeriod.self {
                VStack(alignment: .leading, spacing: IKPadding.small) {
                    Label {
                        Text(STResourcesStrings.Localizable.recommendedDurationsTitle)
                            .font(.ST.calloutMedium)
                    } icon: {
                        STResourcesAsset.Images.leaf.swiftUIImage
                    }
                    .labelStyle(.ikLabel(IKPadding.small))
                    .foregroundStyle(Color.ST.primary)

                    Text(STResourcesStrings.Localizable.recommendedDurationsDescription)
                        .font(.ST.callout)
                        .foregroundStyle(Color.ST.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(value: .medium)
            }

            ForEach(items, id: \.self) { item in
                Button {
                    @InjectService var matomo: MatomoUtils
                    if let category = T.matomoCategoryLocal {
                        matomo.track(eventWithCategory: category, name: item.matomoName)
                    }
                    onSelection(item)
                    dismiss()
                } label: {
                    SettingSelectableCell(item: item, selectedItem: selected)
                }

                if item != items.last,
                   T.self != ValidityPeriod.self || item == items.last(where: { $0.rightImage != nil }) {
                    DividerView()
                        .padding(.horizontal, value: .medium)
                }
            }
        }
        .padding(.vertical, value: .medium)
    }
}

#Preview {
    SettingSelectableList(
        ValidityPeriod.self,
        selected: ValidityPeriod.one
    ) { _ in }
}
