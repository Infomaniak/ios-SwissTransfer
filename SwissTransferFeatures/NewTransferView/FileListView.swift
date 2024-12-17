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
                    removeAction: RemoveFileAction {
                        newTransferManager.remove(file: $0) {
                            files = newTransferManager.filesAt(folderURL: folder?.localURL)
                        }
                    }
                )
            }
            .padding(value: .medium)
        }
        .appBackground()
        .floatingActionButton(selection: $selectedItems, style: .newTransfer)
        .stNavigationBarStyle()
        .stNavigationBarNewTransfer(title: navigationTitle)
        .onAppear {
            files = newTransferFileManager.filesAt(folderURL: folder?.localURL)
        }
        .onChange(of: files) { _ in
            if files.isEmpty {
                dismiss()
            }
        }
        .task(id: selectedItems) {
            files = await newTransferFileManager.addItems(selectedItems)
        }
    }

    func removeFile(_ file: DisplayableFile, atFolderURL folderURL: URL?) {
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
