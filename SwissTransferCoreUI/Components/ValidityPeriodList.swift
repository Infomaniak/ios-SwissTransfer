/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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

public struct ValidityPeriodList: View {
    @Environment(\.currentSession) private var currentSession
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingAvailabilityAlert = false

    let items = Array(ValidityPeriod.allCases)
    let selected: ValidityPeriod?
    let confirmationButtonTitle: String
    let onSelection: (ValidityPeriod) -> Void

    public init(
        selected: ValidityPeriod?,
        confirmationButtonTitle: String = STResourcesStrings.Localizable.buttonConfirm,
        onSelection: @escaping (ValidityPeriod) -> Void
    ) {
        self.selected = selected
        self.confirmationButtonTitle = confirmationButtonTitle
        self.onSelection = onSelection
    }

    public var body: some View {
        VStack(spacing: 0) {
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

            ForEach(items, id: \.self) { period in
                Button {
                    if period == .thirty, currentSession?.userProfile != nil {
                        isShowingAvailabilityAlert = true
                    } else {
                        select(period)
                    }
                } label: {
                    SettingSelectableCell(item: period, selectedItem: selected)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(period.title)
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("\(String(describing: ValidityPeriod.self))_\(period.matomoName)")

                if period != items.last {
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
                    select(.thirty)
                }
            }
        }
    }

    private func select(_ period: ValidityPeriod) {
        @InjectService var matomo: MatomoUtils
        if let category = ValidityPeriod.matomoCategoryLocal {
            matomo.track(eventWithCategory: category, name: period.matomoName)
        }
        onSelection(period)
        dismiss()
    }
}

#Preview {
    ValidityPeriodList(selected: .one) { _ in }
}
