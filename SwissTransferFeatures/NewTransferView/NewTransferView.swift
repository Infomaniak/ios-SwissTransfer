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
import SwissTransferCoreUI

public struct NewTransferView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {
        files = ["file 1", "file 2", "file 3", "file 4", "file 5", "file 6", "file 7", "file 8"]
    }

    private let files: [String] // File to upload
    private let filesSize = 8561 // Size of files
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(STResourcesStrings.Localizable.filesCount(files.count)) · \(filesSize.formatted(.defaultByteCount))")

                    LazyVGrid(
                        columns: columns,
                        alignment: .center,
                        spacing: 16,
                        pinnedViews: []
                    ) {
                        ForEach(files, id: \.self) { file in
                            LargeThumbnailView(
                                fileName: file,
                                fileSize: 8561,
                                thumbnail: STResourcesAsset.Images.fileAdobe.swiftUIImage
                            )
                        }
                    }
                    Spacer()
                }
                .padding(value: .medium)
            }
            .floatingContainer {
                VStack(spacing: 0) {
                    Button {
                        // Import files
                    } label: {
                        Label(
                            title: { Text(STResourcesStrings.Localizable.buttonAddFiles) },
                            icon: { STResourcesAsset.Images.plus.swiftUIImage }
                        )
                    }
                    .buttonStyle(.ikBorderless)

                    NavigationLink {
                        //
                    } label: {
                        Text(STResourcesStrings.Localizable.buttonNext)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.ikBorderedProminent)
                }
                .ikButtonFullWidth(true)
                .controlSize(.large)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(STResourcesStrings.Localizable.importFilesScreenTitle)
                        .font(.ST.title2)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .stNavigationBarStyle()
        }
    }
}

#Preview {
    NewTransferView()
}
