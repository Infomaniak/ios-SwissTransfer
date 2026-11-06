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

import InfomaniakCoreCommonUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct TransferDetailsMenu: View {
    @State private var transferToDelete: TransferUi?

    private let transfer: TransferUi

    public init(transfer: TransferUi) {
        self.transfer = transfer
    }

    public var body: some View {
        Group {
            if transfer.direction == .received {
                Menu {
                    ReportTransferButton(transfer: transfer)
                    DeleteTransferButton(
                        transfer: transfer,
                        transferToDelete: $transferToDelete
                    )
                } label: {
                    Label {
                        Text(STResourcesStrings.Localizable.moreButton)
                    } icon: {
                        STResourcesAsset.Images.plusActions.swiftUIImage
                    }
                }
            } else {
                DeleteTransferButton(
                    transfer: transfer,
                    transferToDelete: $transferToDelete
                )
            }
        }
        .stCustomAlert(item: $transferToDelete) { transfer in
            DeleteTransferAlertView(transfer: transfer)
        }
    }
}
