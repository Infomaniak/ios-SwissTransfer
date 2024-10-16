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
    @Environment(\.isCompactWindow) private var isCompactWindow
    @EnvironmentObject private var mainViewState: MainViewState

    @StateObject private var viewModel: TransferListViewModel

    private let origin: TransferOrigin

    public init(transfers: [TransferUi], origin: TransferOrigin) {
        _viewModel = StateObject(wrappedValue: TransferListViewModel(transfers: transfers))
        self.origin = origin
    }

    public var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            if isCompactWindow {
                Text(origin.title)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)
                    .padding(.horizontal, value: .medium)
                    .padding(.top, value: .medium)
                    .listRowInsets(EdgeInsets(.zero))
                    .listRowSeparator(.hidden)
            }

            ForEach(viewModel.sections ?? []) { section in
                Section {
                    ForEach(section.transfers, id: \.uuid) { transfer in
                        TransferCell(transfer: transfer)
                            .tag(NavigationDestination.transfer(transfer))
                    }
                } header: {
                    Text(section.title)
                        .sectionHeader()
                        .padding(.horizontal, value: .medium)
                }
                .listRowInsets(EdgeInsets(.zero))
                .listRowSeparator(.hidden)
            }
        }
        .listRowSpacing(0)
        .listStyle(.plain)
        .appBackground()
        .toolbar {
            ToolbarItem(placement: .principal) {
                if !isCompactWindow {
                    Text(origin.title)
                        .font(.ST.title2)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    TransferList(
        transfers: [
            PreviewHelper.sampleTransfer,
            PreviewHelper.sampleTransfer,
            PreviewHelper.sampleOldTransfer,
            PreviewHelper.sampleTransfer
        ],
        origin: .sent
    )
}
