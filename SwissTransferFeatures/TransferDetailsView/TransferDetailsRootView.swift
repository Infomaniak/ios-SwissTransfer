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

import InfomaniakDI
import STCore
import SwiftUI
import SwissTransferCore

@MainActor
final class TransferDetailsViewModel: ObservableObject {
    @Published var transfer: TransferUi?
    @Published var status: TransferStatus

    private var flow: (any AsyncSequence)?

    init(data: TransferData) {
        switch data {
        case .transfer(let transfer):
            self.transfer = transfer
            status = transfer.transferStatus ?? .unknown
        case .status(let transferStatus):
            status = transferStatus
        }

        if let transfer {
            Task {
                await fetchTransfer(uuid: transfer.uuid)
            }
            Task {
                try await observeTransfer(uuid: transfer.uuid)
            }
        }
    }

    private func fetchTransfer(uuid: String) async {
        @InjectService var accountManager: SwissTransferCore.AccountManager
        let currentManager = await accountManager.getCurrentManager()

        try? await currentManager?.fetchTransfer(transferUUID: uuid)
    }

    private func observeTransfer(uuid: String) async throws {
        @InjectService var accountManager: SwissTransferCore.AccountManager
        guard let currentManager = await accountManager.getCurrentManager() else { return }

        flow = try currentManager.getTransferFlow(transferUUID: uuid)
        guard let flow else { return }

        for try await flowResult in flow {
            guard let newTransfer = flowResult as? TransferUi else { continue }

            transfer = newTransfer
            if let transferStatus = newTransfer.transferStatus {
                status = transferStatus
            }
        }
    }
}

public struct TransferDetailsRootView: View {
    @StateObject private var viewModel: TransferDetailsViewModel

    public init(data: TransferData) {
        _viewModel = .init(wrappedValue: .init(data: data))
    }

    public var body: some View {
        NavigationStack {
            let transfer = viewModel.transfer
            switch viewModel.status {
            case .ready, .unknown:
                TransferDetailsView(transfer: transfer)
            case .expiredDate:
                ExpiredTransferView(expirationType: .date)
            case .expiredDownloadQuota:
                let downloadLimit = downloadLimit(transfer)
                ExpiredTransferView(expirationType: .downloadQuota(downloadLimit))
            case .waitVirusCheck:
                VirusCheckView()
            case .virusDetected:
                VirusDetectedView()
            }
        }
    }

    private func downloadLimit(_ transfer: TransferUi?) -> Int? {
        var quota: Int?
        if let downloadLimit = transfer?.downloadLimit {
            quota = Int(downloadLimit)
        }

        return quota
    }
}
