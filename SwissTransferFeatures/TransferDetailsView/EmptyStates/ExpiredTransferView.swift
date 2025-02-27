/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

import STCore
import STResources
import SwiftUI
import SwissTransferCoreUI

struct ExpiredTransferView: View {
    enum ExpirationType {
        case date
        case downloadQuota(Int?)
    }

    @Environment(\.dismiss) private var dismiss
    private let expirationType: ExpirationType

    var subtitle: String {
        switch expirationType {
        case .date:
            return STResourcesStrings.Localizable.transferExpiredDescription
        case .downloadQuota(let count):
            guard let count else {
                return STResourcesStrings.Localizable.deeplinkTransferExpired
            }
            guard count > 1 else {
                return STResourcesStrings.Localizable.transferExpiredLimitReachedDescriptionPlural(count)
            }
            return STResourcesStrings.Localizable.transferExpiredLimitReachedDescriptionPluralMany(count)
        }
    }

    init(expirationType: ExpirationType) {
        self.expirationType = expirationType
    }

    var body: some View {
        IllustrationAndTextView(
            image: STResourcesAsset.Images.ghostQuestionMarksShareLink.swiftUIImage,
            title: STResourcesStrings.Localizable.transferExpiredTitle,
            subtitle: subtitle,
            style: .emptyState
        )
        .padding(value: .medium)
        .scrollableEmptyState()
        .appBackground()
        .stNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

#Preview {
    ExpiredTransferView(expirationType: .date)
}
