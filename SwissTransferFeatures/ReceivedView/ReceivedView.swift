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
import STTransferDetailsView
import STTransferList
import SwiftUI
import SwissTransferCore

public struct ReceivedView: View {
    @State private var viewRouter = ViewRouter()
    @State private var transfers = [PreviewHelper.sampleTransfer, PreviewHelper.sampleTransfer]

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewRouter.path) {
            TransferList(transfers: transfers) { transfer in
                viewRouter.navigate(to: transfer)
            }
            .navigationDestination(for: NavigableTransfer.self) { navTransfer in
                TransferDetailsView(transfer: navTransfer.transfer)
            }
            .stNavigationBar()
        }
        .environmentObject(viewRouter)
    }
}

#Preview {
    ReceivedView()
}
