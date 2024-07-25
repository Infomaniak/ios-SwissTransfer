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

struct SentList: View {
    var body: some View {
        List {
            Text(STResourcesStrings.Localizable.sharedFilesTitle)
                .font(.ST.title)
                .foregroundStyle(STResourcesAsset.Colors.greyOrca.swiftUIColor)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .listRowInsets(EdgeInsets(.zero))
                .listRowSeparator(.hidden)

            Section {
                SentCell(itemCount: 6)
                SentCell(itemCount: 3)
                SentCell(itemCount: 4)
                SentCell(itemCount: 2)
            } header: {
                Text("Aujourd'hui")
                    .font(.ST.callout)
                    .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)
                    .padding(.horizontal, 16)
            }
            .listRowInsets(EdgeInsets(.zero))
            .listRowSeparator(.hidden)

            Section {
                SentCell(itemCount: 3)
            } header: {
                Text("Hier")
                    .font(.ST.callout)
                    .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)
                    .padding(.horizontal, 16)
            }
            .listRowInsets(EdgeInsets(.zero))
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(0)
        .listStyle(.plain)
        .floatingActionButton(style: .newTransfer) {
            // Transfer
        }
    }
}

#Preview {
    SentList()
}
