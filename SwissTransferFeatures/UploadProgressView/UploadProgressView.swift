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
import STNetwork
import SwiftUI
import SwissTransferCore

public struct UploadProgressView: View {
    @EnvironmentObject private var transferManager: TransferManager

    @StateObject private var transferSessionManager = TransferSessionManager()

    @State private var error: Error?

    let uploadSession: NewUploadSession

    public init(uploadSession: NewUploadSession) {
        self.uploadSession = uploadSession
    }

    public var body: some View {
        VStack {
            ProgressView(value: transferSessionManager.percentCompleted)
        }
        .onAppear {
            Task {
                do {
                    let transferUUID = try await transferSessionManager.startUpload(session: uploadSession)
                    guard let transfer = transferManager.getTransferByUUID(transferUUID: transferUUID) else {
                        fatalError("Couldn't find transfer")
                    }

                    // TODO: Navigate to transfer
                } catch {
                    self.error = error
                }
            }
        }
    }
}

#Preview {
    UploadProgressView(uploadSession: NewUploadSession(
        duration: "30",
        authorEmail: "",
        password: "",
        message: "Coucou",
        numberOfDownload: 250,
        language: .english,
        recipientsEmails: [],
        files: []
    ))
}
