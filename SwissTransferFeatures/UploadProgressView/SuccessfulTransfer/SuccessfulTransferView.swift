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

import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

extension TransferType {
    var successTitle: String {
        switch self {
        case .link:
            return STResourcesStrings.Localizable.uploadSuccessLinkTitle
        case .qrcode, .proximity:
            return STResourcesStrings.Localizable.uploadSuccessQrTitle
        case .mail:
            return STResourcesStrings.Localizable.uploadSuccessEmailTitle
        }
    }
}

public struct SuccessfulTransferView: View {
    private let type: TransferType
    private let recipientsEmails: [String]
    private let dismiss: () -> Void

    public init(type: TransferType, recipientsEmails: [String], dismiss: @escaping () -> Void) {
        self.type = type
        self.recipientsEmails = recipientsEmails
        self.dismiss = dismiss
    }

    public var body: some View {
        Group {
            switch type {
            case .link, .qrcode, .proximity:
                SuccessfulLinkTransferView(type: type, url: URL(string: "https://www.infomaniak.com")!, dismiss: dismiss)
            case .mail:
                SuccessfulMailTransferView(recipients: recipientsEmails, dismiss: dismiss)
            }
        }
        .stIconNavigationBar()
        .background(Color.ST.background)
        .navigationBarBackButtonHidden()
    }
}

#Preview("Mail") {
    SuccessfulTransferView(type: .mail, recipientsEmails: []) {}
}

#Preview("QR Code") {
    SuccessfulTransferView(type: .qrcode, recipientsEmails: []) {}
}

#Preview("Link") {
    SuccessfulTransferView(type: .link, recipientsEmails: []) {}
}
