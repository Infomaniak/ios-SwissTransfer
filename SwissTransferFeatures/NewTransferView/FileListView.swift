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

import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct FileListView: View {
    @EnvironmentObject private var newTransferManager: NewTransferManager

    var files = [UploadFile]()

    private var filesSize: Int64 {
        newTransferManager.uploadFiles.map { $0.size }.reduce(0, +)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(
                    "\(STResourcesStrings.Localizable.filesCount(newTransferManager.uploadFiles.count)) · \(filesSize.formatted(.defaultByteCount))"
                )

                LazyVGrid(
                    columns: columns,
                    alignment: .center,
                    spacing: 16,
                    pinnedViews: []
                ) {
                    ForEach(files) { file in
                        LargeThumbnailView(
                            fileName: file.url.lastPathComponent,
                            fileSize: file.size,
                            url: file.url,
                            mimeType: file.mimeType
                        ) {
                            newTransferManager.remove(file: file)
                        }
                    }
                }
                Spacer()
            }
            .padding(value: .medium)
        }
    }
}

#Preview {
    FileListView()
}
