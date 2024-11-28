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
import STNewTransferView
import STResources
import SwiftUI
import SwissTransferCoreUI

struct SentEmptyView: View {
    @State private var newSelectedItems = [URL]()
    @State private var newTransferContainer: NewTransferContainer?

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: IKPadding.medium) {
                Text(STResourcesStrings.Localizable.sentEmptyTitle)
                    .font(.ST.specificLargeTitleMedium)
                    .foregroundStyle(Color.ST.textPrimary)
                    .multilineTextAlignment(.center)

                Text(STResourcesStrings.Localizable.firstTransferDescription)
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)
                    .multilineTextAlignment(.center)
            }

            FirstTransferButton(selection: $newSelectedItems, style: .big)
                .onChange(of: newSelectedItems) { selectedItems in
                    newTransferContainer = NewTransferContainer(urls: selectedItems)
                }
        }
        .padding(value: .medium)
        .fullScreenCover(item: $newTransferContainer) { container in
            NewTransferView(urls: container.urls)
        }
    }
}

#Preview {
    SentEmptyView()
}
