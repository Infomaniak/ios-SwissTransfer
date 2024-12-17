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
import SwissTransferCore
import SwissTransferCoreUI

public struct RootTransferView: View {
    @StateObject private var viewState = RootTransferViewState()
    @StateObject private var viewModel = RootTransferViewModel()
    @StateObject private var newTransferManager: NewTransferFileManager

    public init(initialItems: [ImportedItem]) {
        _newTransferManager = StateObject(wrappedValue: NewTransferFileManager(initialItems: initialItems))
    }

    public var body: some View {
        ZStack {
            switch viewState.state {
            case .newTransfer:
                NewTransferView()
                    .environmentObject(newTransferManager)
            case .uploadProgress(let uploadSession):
                UploadProgressView(uploadSession: uploadSession)
            case .error:
                UploadErrorView()
            case .success(let transferUUID):
                UploadSuccessView(transferUUID: transferUUID)
            }
        }
        .floatingPanel(item: $viewState.cancelUploadUUID) { container in
            CancelUploadView(uploadSessionUUID: container.uuid)
        }
        .environmentObject(viewState)
        .environmentObject(viewModel)
    }
}

#Preview {
    RootTransferView(initialItems: [])
}
