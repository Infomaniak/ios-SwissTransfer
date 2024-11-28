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
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

extension TransferType {
    var successTitle: String {
        switch self {
        case .link:
            return STResourcesStrings.Localizable.uploadSuccessLinkTitle
        case .qrCode, .proximity:
            return STResourcesStrings.Localizable.uploadSuccessQrTitle
        case .mail:
            return STResourcesStrings.Localizable.uploadSuccessEmailTitle
        }
    }
}

public struct UploadSuccessView: View {
    @EnvironmentObject private var rootTransferViewState: RootTransferViewState
    @EnvironmentObject private var viewModel: RootTransferViewModel

    let transferUUID: String

    public init(transferUUID: String) {
        self.transferUUID = transferUUID
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.transferType {
                case .link, .qrCode, .proximity:
                    UploadSuccessQRCodeView(type: viewModel.transferType, transferUUID: transferUUID)
                case .mail:
                    UploadSuccessMailView(recipients: [viewModel.recipientEmail])
                }
            }
            .stIconNavigationBar()
            .background(Color.ST.background)
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview("Mail") {
    UploadSuccessView(transferUUID: PreviewHelper.sampleTransfer.uuid)
}

#Preview("QR Code") {
    UploadSuccessView(transferUUID: PreviewHelper.sampleTransfer.uuid)
}

#Preview("Link") {
    UploadSuccessView(transferUUID: PreviewHelper.sampleTransfer.uuid)
}
