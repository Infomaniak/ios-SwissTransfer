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
    @StateObject private var viewState: RootTransferViewState
    @StateObject private var viewModel: RootTransferViewModel
    @StateObject private var newTransferManager: NewTransferFileManager

    public init(initialItems: [ImportedItem]) {
        _viewState = StateObject(wrappedValue: RootTransferViewState())
        _viewModel = StateObject(wrappedValue: RootTransferViewModel(initializedFromShare: false))
        _newTransferManager = StateObject(wrappedValue: NewTransferFileManager(initialItems: initialItems))
    }

    public init(localSessionUUID: String) {
        _viewState = StateObject(wrappedValue: RootTransferViewState(
            initialState: .uploadProgress(localSessionUUID: localSessionUUID)
        ))
        _viewModel = StateObject(wrappedValue: RootTransferViewModel(initializedFromShare: true))
        _newTransferManager = StateObject(wrappedValue: NewTransferFileManager(initialItems: [], shouldDoInitialClean: false))
    }

    public var body: some View {
        ZStack {
            switch viewState.state {
            case .newTransfer:
                NewTransferView()
            case .uploadProgress(let localSessionUUID):
                UploadProgressView(localSessionUUID: localSessionUUID)
            case .verifyMail(let newUploadSession):
                VerifyMailView(newUploadSession: newUploadSession)
            case .error(let uploadError):
                UploadErrorView(uploadError: uploadError)
            case .success(let transferUUID):
                UploadSuccessView(transferUUID: transferUUID)
            }
        }
        .stFloatingPanel(item: $viewState.cancelUploadContainer, bottomPadding: .zero) { container in
            CancelUploadView(uploadContainer: container)
        }
        .environmentObject(newTransferManager)
        .environmentObject(viewState)
        .environmentObject(viewModel)
    }
}

#Preview {
    RootTransferView(initialItems: [])
}
