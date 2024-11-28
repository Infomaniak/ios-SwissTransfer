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
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct RootUploadProgressView: View {
    @State private var transferUUID: String?
    @State private var uploadError: Error?

    private let transferType: TransferType
    private let uploadSession: NewUploadSession
    private let dismiss: () -> Void

    public init(transferType: TransferType, uploadSession: NewUploadSession, dismiss: @escaping () -> Void) {
        self.transferType = transferType
        self.uploadSession = uploadSession
        self.dismiss = dismiss
    }

    public var body: some View {
//        Group {
//            if let uploadError {
//                // TODO: Add Error View
//                Text("Error")
//            } else if let transferUUID {
//                SuccessfulTransferView(
//                    type: transferType,
//                    transferUUID: transferUUID,
//                    recipientsEmails: uploadSession.recipientsEmails
//                )
//            } else {
//                UploadProgressView(
//                    transferUUID: $transferUUID,
//                    error: $uploadError,
//                    transferType: transferType,
//                    uploadSession: uploadSession
//                )
//            }
//        }
//        .environment(\.dismissModal, dismiss)

        Text("coucou")
    }
}

#Preview {
    RootUploadProgressView(transferType: .qrCode, uploadSession: PreviewHelper.sampleNewUploadSession) {}
}
