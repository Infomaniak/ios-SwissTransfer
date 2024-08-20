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

import STCore
import STDatabase
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct TransferList: View {
    let transfers: [Transfer]
    let onSelect: (Transfer) -> Void

    public init(transfers: [Transfer], onSelect: @escaping (Transfer) -> Void) {
        self.transfers = []
        self.onSelect = onSelect
    }

    public var body: some View {
        List {
            Text(STResourcesStrings.Localizable.sharedFilesTitle)
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)
                .padding(.horizontal, value: .medium)
                .padding(.top, value: .medium)
                .listRowInsets(EdgeInsets(.zero))
                .listRowSeparator(.hidden)

            Section {
                TransferCell(transfer: PreviewHelper.sampleTransfer)
                    .onTapGesture {
                        onSelect(PreviewHelper.sampleTransfer)
                    }
                TransferCell(transfer: PreviewHelper.sampleTransfer)
                TransferCell(transfer: PreviewHelper.sampleTransfer)
                TransferCell(transfer: PreviewHelper.sampleTransfer)
            } header: {
                Text("Aujourd'hui")
                    .sectionHeader()
                    .padding(.horizontal, value: .medium)
            }
            .listRowInsets(EdgeInsets(.zero))
            .listRowSeparator(.hidden)

            Section {
                TransferCell(transfer: PreviewHelper.sampleTransfer)
            } header: {
                Text("Hier")
                    .sectionHeader()
                    .padding(.horizontal, value: .medium)
            }
            .listRowInsets(EdgeInsets(.zero))
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(0)
        .listStyle(.plain)
    }
}

#Preview {
    TransferList(
        transfers: [PreviewHelper.sampleTransfer, PreviewHelper.sampleTransfer, PreviewHelper.sampleTransfer]
    ) { _ in }
}
