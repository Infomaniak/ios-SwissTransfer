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
import STResources
import STTransferDetailsView
import STTransferList
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct SentView: View {
    @State private var viewRouter = ViewRouter()
    @State private var transfers: [Transfer]

    public init(transfers: [Transfer]) {
        self.transfers = transfers
    }

    public var body: some View {
        NavigationStack(path: $viewRouter.path) {
            Group {
                if transfers.isEmpty {
                    SentEmptyView()
                } else {
                    TransferList(transfers: []) { transfer in
                        viewRouter.navigate(to: transfer)
                    }
                    .floatingActionButton(style: .newTransfer) {
                        // New transfer
                    }
                }
            }
            .navigationDestination(for: NavigableTransfer.self) { value in
                TransferDetailsView(title: "Rapport d'oral - Master 2")
            }
            .stNavigationBar()
        }
        .environmentObject(viewRouter)
    }
}

#Preview("SentView") {
    SentView(transfers: [PreviewHelper.sampleTransfer])
}

#Preview("Empty SentView") {
    SentView(transfers: [])
}
