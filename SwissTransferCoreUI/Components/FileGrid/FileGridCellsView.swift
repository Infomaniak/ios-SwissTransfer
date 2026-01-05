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
import InfomaniakCoreSwiftUI
import STCore
import SwiftUI
import SwissTransferCore

public struct FileGridCellsView: View {
    @ObservedObject private var multipleSelectionViewModel: MultipleSelectionViewModel

    private let files: [any DisplayableFile]
    private let transfer: TransferUi?
    private let action: (any LargeFileCellAction)?
    private let matomoCategory: MatomoCategory

    public init(
        files: [any DisplayableFile],
        transfer: TransferUi? = nil,
        action: (any LargeFileCellAction)? = nil,
        multipleSelectionViewModel: MultipleSelectionViewModel = MultipleSelectionViewModel(),
        matomoCategory: MatomoCategory
    ) {
        self.files = files
        self.transfer = transfer
        self.action = action
        self.multipleSelectionViewModel = multipleSelectionViewModel
        self.matomoCategory = matomoCategory
    }

    public var body: some View {
        ForEach(files, id: \.id) { file in
            if file.isFolder {
                NavigationLink(value: file) {
                    if let transfer,
                       let fileUi = file as? FileUi {
                        let isMultiSelected = Binding {
                            multipleSelectionViewModel.isSelected(file: fileUi)
                        } set: { _ in
                            multipleSelectionViewModel.toggleSelection(of: fileUi)
                        }
                        DownloadableFileCellView(
                            transfer: transfer,
                            file: fileUi,
                            isMultiSelectionEnabled: multipleSelectionViewModel.isEnabled,
                            isSelected: isMultiSelected,
                            matomoCategory: matomoCategory
                        )
                        .onLongPressGesture {
                            multipleSelectionViewModel.toggleSelection(of: fileUi)
                        }
                    } else {
                        LargeFileCell(
                            file: file,
                            transferUUID: transfer?.uuid,
                            action: action
                        )
                    }
                }
            } else {
                if let transfer, let fileUi = file as? FileUi {
                    let isMultiSelected = Binding {
                        multipleSelectionViewModel.isSelected(file: fileUi)
                    } set: { _ in
                        multipleSelectionViewModel.toggleSelection(of: fileUi)
                    }
                    DownloadableFileCellView(
                        transfer: transfer,
                        file: fileUi,
                        isMultiSelectionEnabled: multipleSelectionViewModel.isEnabled,
                        isSelected: isMultiSelected,
                        matomoCategory: matomoCategory
                    )
                    .onLongPressGesture {
                        multipleSelectionViewModel.toggleSelection(of: fileUi)
                    }
                } else if let transferableFile = file as? TransferableFile {
                    TransferableFileCellView(
                        file: transferableFile,
                        transferUUID: transfer?.uuid,
                        action: action
                    )
                } else {
                    LargeFileCell(
                        file: file,
                        transferUUID: transfer?.uuid,
                        action: action
                    )
                }
            }
        }
        .onChange(of: multipleSelectionViewModel.toggleSelectAll) { _ in
            let filesUi: [FileUi] = self.files.compactMap { $0 as? FileUi }
            multipleSelectionViewModel.selectAll(files: filesUi)
        }
    }
}

#Preview {
    FileGridCellsView(files: [], transfer: nil, matomoCategory: .sentTransfer)
}
