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

import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct ContentView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    let files: [FileUi]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(STResourcesStrings.Localizable.transferContentHeader)
                .sectionHeader()

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 16,
                pinnedViews: []
            ) {
                ForEach(files, id: \.uid) { file in
                    LargeThumbnailView(fileName: file.fileName, fileSize: file.fileSize, thumbnail: file.thumbnail)
                }
            }
        }
    }
}

#Preview {
    ContentView(files: [PreviewHelper.sampleFile, PreviewHelper.sampleFile, PreviewHelper.sampleFile])
}
