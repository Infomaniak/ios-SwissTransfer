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

import STNewTransferView
import STUploadProgressView
import SwiftUI
import SwissTransferCoreUI

import SwissTransferCore

public struct RootTransferView: View {
    @StateObject private var viewState = RootTransferViewState()

    private let initialFiles: [URL]

    public init(initialFiles: [URL]) {
        self.initialFiles = initialFiles
    }

    public var body: some View {
        Group {
            switch viewState.state {
            case .newTransfer:
                NewTransferView(urls: initialFiles)
            case .uploadProgress(let newUploadSession):
                UploadProgressView(uploadSession: newUploadSession)
            case .error:
                Text("Error")
            case .success(let transferUUID, let recipientsEmails):
                UploadSuccessView(transferUUID: transferUUID, recipientsEmails: recipientsEmails)
            }
        }
        .environmentObject(viewState)
    }
}

#Preview {
    RootTransferView(initialFiles: [])
}
