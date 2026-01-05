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

import DesignSystem
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct FileListView: View {
    @StateObject private var files: FlowObserver<[FileUi]>

    private let title: String
    private let transfer: TransferUi?
    private let multipleSelectionViewModel: MultipleSelectionViewModel

    private var filesCount: Int {
        files.value?.count ?? 0
    }

    private var filesSize: Int64 {
        files.value?.filesSize() ?? 0
    }

    private let matomoCategory: MatomoCategory

    init(folder: FileUi, transfer: TransferUi?, multipleSelectionViewModel: MultipleSelectionViewModel = MultipleSelectionViewModel(), matomoCategory: MatomoCategory) {
        @LazyInjectService var injection: SwissTransferInjection
        let children = injection.fileManager.getFilesFromTransfer(folderUuid: folder.uid)

        title = folder.fileName
        _files = StateObject(wrappedValue: FlowObserver(flow: children))

        self.transfer = transfer
        self.multipleSelectionViewModel = multipleSelectionViewModel
        self.matomoCategory = matomoCategory
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IKPadding.medium) {
                FilesCountAndSizeView(count: filesCount, size: filesSize)
                    .foregroundStyle(Color.ST.textPrimary)
                    .font(.ST.callout)

                FileGridLayoutView {
                    FileGridCellsView(files: files.value ?? [], transfer: transfer, multipleSelectionViewModel: multipleSelectionViewModel, matomoCategory: matomoCategory)
                }
            }
            .padding(value: .medium)
        }
        .stNavigationBarStyle()
        .matomoView(view: .transferDetailsFileList)
        .stNavigationBarMultipleSelection(title: title, closeButtonPlacement: .topBarTrailing, multipleSelectionViewModel: multipleSelectionViewModel)
    }
}

#Preview {
    FileListView(folder: PreviewHelper.sampleFolder, transfer: nil, matomoCategory: .sentTransfer)
}
