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
import STNewTransferView
import STResources
import STTransferDetailsView
import STTransferList
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct SentView: View {
    @EnvironmentObject private var transferManager: TransferManager
    @State private var newTransferContainer: NewTransferContainer?

    public init() {}

    public var body: some View {
        TransferList(transferManager: transferManager, origin: .sent) {
            SentEmptyView()
        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            if case .transfer(let transfer) = destination {
                TransferDetailsView(transfer: transfer)
            }
        }
        .floatingActionButton(style: .newTransfer) {
            showNewTransferSheet = true
        }
        .fullScreenCover(item: $newTransferContainer) { container in
            NewTransferView(urls: container.urls)
        }
    }
}

#Preview("SentView") {
    SentView()
}
