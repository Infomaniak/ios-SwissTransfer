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

    private let transferManager: TransferManager

    private var flow: (any AsyncSequence)?

    init(data: TransferData, transferManager: TransferManager) {
        self.transferManager = transferManager
        switch data {
        case .transfer(let transfer):
            self.transfer = transfer
            status = transfer.transferStatus ?? .unknown
        case .status(let transferStatus):
            status = transferStatus
        }

        if let transfer {
            Task {
                try? await transferManager.fetchTransfer(transferUUID: transfer.uuid)
            }
            Task {
                try await observeTransfer(uuid: transfer.uuid)
            }
        }
    }

    private func observeTransfer(uuid: String) async throws {
        flow = try transferManager.getTransferFlow(transferUUID: uuid)
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

    public init(data: TransferData, transferManager: TransferManager) {
        _viewModel = .init(wrappedValue: .init(data: data, transferManager: transferManager))
    }

    public var body: some View {
        NavigationStack {
            let transfer = viewModel.transfer
            switch viewModel.status {
            case .ready, .unknown:
                TransferDetailsView(transfer: transfer)
            case .expiredDate:
                ExpiredTransferView(transfer: transfer, expirationType: .date(transfer?.expirationDate))
            case .expiredDownloadQuota:
                ExpiredTransferView(transfer: transfer, expirationType: .downloadQuota(transfer?.downloadLimit))
            case .waitVirusCheck:
                VirusCheckView()
            case .virusDetected:
                VirusDetectedView(transfer: transfer)
            }
        }
    }
}
