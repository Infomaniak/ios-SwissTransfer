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

import InfomaniakCoreSwiftUI
import STCore
import SwiftUI
import SwissTransferCore

public struct FileGridCellsView: View {
    private let files: [any DisplayableFile]
    private let transfer: TransferUi?
    private let removeAction: RemoveFileAction?

    public init(files: [any DisplayableFile], transfer: TransferUi? = nil, removeAction: RemoveFileAction? = nil) {
        self.files = files
        self.transfer = transfer
        self.removeAction = removeAction
    }

    public var body: some View {
        ForEach(files, id: \.id) { file in
            if file.isFolder {
                NavigationLink(value: file) {
                    LargeFileCell(
                        file: file,
                        transferUUID: transfer?.uuid,
                        removeAction: removeAction
                    )
                }
            } else {
                if let transfer, let fileUi = file as? FileUi {
                    DownloadableFileCellView(transfer: transfer, file: fileUi)
                } else {
                    LargeFileCell(
                        file: file,
                        transferUUID: transfer?.uuid,
                        removeAction: removeAction
                    )
                }
            }
        }
    }
}

#Preview {
    FileGridCellsView(files: [], transfer: nil)
}
