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
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI
import InfomaniakDI

@MainActor
final class TransferDetailsViewModel: ObservableObject {
    @Published var transfer: TransferUi?
    @Published var state: TransferState

    init(data: TransferData) {
        transfer = data.transfer
        state = data.state ?? .ready
    }

    func fetchTransfer() async {
        guard let transfer else { return }

        @InjectService var accountManager: SwissTransferCore.AccountManager
        let currentManager = await accountManager.getCurrentManager()

        do {
            try await currentManager?.fetchTransfer(transferUUID: transfer.uuid)
        } catch {
            // TODO: Handle state update here
            print("here")
        }
    }
}

public struct TransferDetailsRootView: View {
    @StateObject private var viewModel: TransferDetailsViewModel

    public init(data: TransferData) {
        _viewModel = .init(wrappedValue: .init(data: data))
    }

    public var body: some View {
        ZStack {
            switch viewModel.state {
            case .ready:
                if let transfer = viewModel.transfer {
                    TransferDetailsView(transfer: transfer)
                }
            case .expired:
                Text("Expired")
            case .waitVirusCheck:
                Text("Wait Virus Check")
            case .virusFlagged:
                Text("Virus Flagged")
            }
        }
        .task {
            await viewModel.fetchTransfer()
        }
    }
}
