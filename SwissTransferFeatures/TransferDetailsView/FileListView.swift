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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct FileListView: View {
    @StateObject private var files: FlowObserver<[FileUi]>

    private let title: String

    private var filesCount: Int {
        files.value?.count ?? 0
    }

    private var filesSize: Int64 {
        files.value?.filesSize() ?? 0
    }

    init(folder: FileUi) {
        @LazyInjectService var injection: SwissTransferInjection
        let children = injection.fileManager.getFilesFromTransfer(folderUuid: folder.uid)

        title = folder.fileName
        _files = StateObject(wrappedValue: FlowObserver(flow: children))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IKPadding.medium) {
                Text(
                    "\(STResourcesStrings.Localizable.filesCount(filesCount)) · \(filesSize.formatted(.defaultByteCount))"
                )

                FileGridView(files: files.value ?? [])
            }
            .padding(value: .medium)
        }
        .stNavigationBarStyle()
        .stNavigationTitle(title)
    }
}

#Preview {
//    InnerContentView(folder: "")
}
