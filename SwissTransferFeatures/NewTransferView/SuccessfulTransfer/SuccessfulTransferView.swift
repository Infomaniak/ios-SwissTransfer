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

import SwiftUI

struct SuccessfulTransferView: View {
    let type: TransferType
    let dismiss: () -> Void

    var body: some View {
        switch type {
        case .link, .qrcode, .proximity:
            SuccesfulLinkTransferView(type: type, url: URL(string: "https://www.infomaniak.com")!, dismiss: dismiss)
        case .mail:
            SuccessfulMailTransferView(recipients: [], dismiss: dismiss)
        }
    }
}

#Preview("Mail") {
    SuccessfulTransferView(type: .mail) {}
}

#Preview("QR Code") {
    SuccessfulTransferView(type: .qrcode) {}
}

#Preview("Link") {
    SuccessfulTransferView(type: .link) {}
}
