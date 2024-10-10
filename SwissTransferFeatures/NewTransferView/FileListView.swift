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

import InfomaniakCoreUI
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct FileListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var newTransferManager: NewTransferManager

    private var files: [DisplayableFile] {
        if let folder {
            return folder.children
        }
        return newTransferManager.displayableFiles
    }

    private let folder: DisplayableFile?

    init(parentFolder: DisplayableFile?) {
        folder = parentFolder
    }

    private var filesSize: Int64 {
        files.map { $0.computedSize }.reduce(0, +)
    }

    private let columns = [
        GridItem(.flexible(), spacing: IKPadding.medium),
        GridItem(.flexible(), spacing: IKPadding.medium)
    ]

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
                                LargeThumbnailView(folderName: file.name, folderSize: file.computedSize) {
                                    newTransferManager.remove(file: file)
                                }
                            }
                        } else {
                            LargeThumbnailView(
                                fileName: file.name,
                                fileSize: file.computedSize,
                                url: file.url,
                                mimeType: file.mimeType
                            ) {
                                newTransferManager.remove(file: file)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(value: .medium)
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
