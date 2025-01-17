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

import InfomaniakCoreSwiftUI
import OSLog
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct FileListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var newTransferFileManager: NewTransferFileManager

    @State private var selectedItems = [ImportedItem]()
    @State private var files = [TransferableFile]()

    private let folder: TransferableFile?

    private var navigationTitle: String {
        guard let folder else {
            return STResourcesStrings.Localizable.importFilesScreenTitle
        }
        return folder.fileName
    }

    init(parentFolder: TransferableFile?) {
        folder = parentFolder
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IKPadding.medium) {
                Text(
                    "\(STResourcesStrings.Localizable.filesCount(files.count)) · \(files.filesSize().formatted(.defaultByteCount))"
                )

                FileGridView(
                    files: files,
                    transfer: nil,
                    removeAction: RemoveFileAction {
                        removeFile($0, atFolderURL: folder?.localURL(in: ""))
                    }
                )
            }
            .padding(value: .medium)
        }
        .appBackground()
        .floatingActionButton(isShowing: folder == nil, selection: $selectedItems, style: .newTransfer)
        .stNavigationBarStyle()
        .stNavigationBarFullScreen(title: navigationTitle)
        .onAppear {
            files = newTransferFileManager.filesAt(folderURL: folder?.localURL(in: ""))
        }
        .onChange(of: files) { _ in
            if files.isEmpty {
                dismiss()
            }
        }
        .task(id: selectedItems) {
            _ = await newTransferFileManager.addItems(selectedItems)
            files = newTransferFileManager.filesAt(folderURL: folder?.localURL(in: ""))
        }
    }

    func removeFile(_ file: TransferableFile, atFolderURL folderURL: URL?) {
        do {
            try newTransferFileManager.remove(file: file)
            let newFiles = newTransferFileManager.filesAt(folderURL: folderURL)

            withAnimation {
                files = newFiles
            }
        } catch {
            Logger.general.error("An error occurred while removing file: \(error)")
        }
    }
}

#Preview {
    FileListView(parentFolder: nil)
}
