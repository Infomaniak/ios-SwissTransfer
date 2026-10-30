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
    @Environment(\.currentSession) private var currentSession
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingAvailabilityAlert = false

    let items: [T]
    let selected: T?
    let confirmationButtonTitle: String
    let onSelection: (T) -> Void

    public init(
        _ type: T.Type,
        selected: T?,
        confirmationButtonTitle: String = STResourcesStrings.Localizable.buttonConfirm,
        onSelection: @escaping (T) -> Void
    ) {
        items = Array(type.allCases)
        self.selected = selected
        self.confirmationButtonTitle = confirmationButtonTitle
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
                    if let period = item as? ValidityPeriod,
                       period == .thirty,
                       currentSession?.userProfile != nil {
                        isShowingAvailabilityAlert = true
                    } else {
                        select(item)
                    }
                } label: {
                    SettingSelectableCell(item: item, selectedItem: selected)
                }

                if item != items.last {
                    DividerView()
                        .padding(.horizontal, value: .medium)
                }
            }
        }
        .padding(.vertical, value: .medium)
        .stCustomAlert(isPresented: $isShowingAvailabilityAlert) {
            VStack(alignment: .leading, spacing: IKPadding.large) {
                Text(STResourcesStrings.Localizable.transferAvailabilityAlertTitle)
                    .font(.ST.headline)
                    .foregroundStyle(Color.ST.textPrimary)

                Text(STResourcesStrings.Localizable.transferAvailabilityAlertDescription)
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)

                ModalButtonsView(
                    primaryButtonTitle: confirmationButtonTitle,
                    secondaryButtonTitle: STResourcesStrings.Localizable.buttonCancel
                ) {
                    if let item = ValidityPeriod.thirty as? T {
                        select(item)
                    }
                }
            }
        }
    }

    private func select(_ item: T) {
        @InjectService var matomo: MatomoUtils
        if let category = T.matomoCategoryLocal {
            matomo.track(eventWithCategory: category, name: item.matomoName)
        }
        onSelection(item)
        dismiss()
    }
}

#Preview {
    SettingSelectableList(
        ValidityPeriod.self,
        selected: ValidityPeriod.one
    ) { _ in }
}
