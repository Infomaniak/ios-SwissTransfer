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

import STResources
import SwiftUI
import SwissTransferCoreUI

struct SentListView: View {
    var body: some View {
        List {
            Text("Fichiers partagés")
                .font(.header1)
                .foregroundStyle(STResourcesAsset.Colors.greyOrca.swiftUIColor)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)

            Section {
                SentItemView(itemCount: 6)
                    .padding(.horizontal, 16)
                SentItemView(itemCount: 3)
                    .padding(.horizontal, 16)
                SentItemView(itemCount: 4)
                    .padding(.horizontal, 16)
                SentItemView(itemCount: 2)
                    .padding(.horizontal, 16)
            } header: {
                Text("Aujourd'hui")
                    .font(.bodySmallRegular)
                    .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)
                    .padding(.horizontal, 16)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)

            Section {
                SentItemView(itemCount: 3)
                    .padding(.horizontal, 16)
            } header: {
                Text("Hier")
                    .font(.bodySmallRegular)
                    .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)
                    .padding(.horizontal, 16)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(8)
        .listStyle(.plain)
        .floatingActionButton(style: .newTransfer) {
            // Transfer
        }
    }
}

#Preview {
    SentListView()
}
