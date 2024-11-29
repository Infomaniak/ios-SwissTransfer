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
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct FileListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var newTransferManager: NewTransferManager

    @State private var files = [DisplayableFile]()

    private let folder: DisplayableFile?
    private let columns = [
        GridItem(.flexible(), spacing: IKPadding.medium),
        GridItem(.flexible(), spacing: IKPadding.medium)
    ]

    private var navigationTitle: String {
        guard let folder else {
            return STResourcesStrings.Localizable.importFilesScreenTitle
        }
        return folder.name
    }

    private var filesSize: Int64 {
        files.map { $0.size }.reduce(0, +)
    }

    init(parentFolder: DisplayableFile?) {
        folder = parentFolder
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IKPadding.medium) {
                Text(
                    "\(STResourcesStrings.Localizable.filesCount(files.count)) · \(filesSize.formatted(.defaultByteCount))"
                )

                LazyVGrid(
                    columns: columns,
                    alignment: .center,
                    spacing: IKPadding.medium,
                    pinnedViews: []
                ) {
                    ForEach(files) { file in
                        if file.isFolder {
                            NavigationLink(value: file) {
                                LargeFileCell(folderName: file.name, folderSize: file.size) {
                                    newTransferManager.remove(file: file) {
                                        files = newTransferManager.filesAt(folderURL: folder?.url)
                                    }
                                }
                            }
                        } else {
                            LargeFileCell(
                                fileName: file.name,
                                fileSize: file.size,
                                url: file.url,
                                mimeType: file.mimeType
                            ) {
                                newTransferManager.remove(file: file) {
                                    files = newTransferManager.filesAt(folderURL: folder?.url)
                                }
                            }
                        }
                    }
                }
            }
            .padding(value: .medium)
        }
        .stNavigationBarStyle()
        .stNavigationBarNewTransfer(title: navigationTitle)
        .onAppear {
            files = newTransferManager.filesAt(folderURL: folder?.url)
        }
        .onChange(of: files) { _ in
            if files.isEmpty {
                dismiss()
            }
        }
    }
}

#Preview {
    FileListView(parentFolder: nil)
}
