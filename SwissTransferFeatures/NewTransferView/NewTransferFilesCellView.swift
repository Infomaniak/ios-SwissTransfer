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

struct NewTransferFilesCellView: View {
    @EnvironmentObject private var newTransferManager: NewTransferManager

    @State private var newSelectedItems = [URL]()
    @State private var files = [DisplayableFile]()

    private var filesSize: Int64 {
        files.map { $0.size }.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Text(STResourcesStrings.Localizable.myFilesTitle)
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textPrimary)

            VStack(alignment: .leading, spacing: IKPadding.medium) {
                NavigationLink(value: DisplayableRootFolder()) {
                    HStack {
                        Text(
                            "\(STResourcesStrings.Localizable.filesCount(files.count)) · \(filesSize.formatted(.defaultByteCount))"
                        )
                        .font(.ST.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        STResourcesAsset.Images.chevronRight.swiftUIImage
                            .iconSize(.medium)
                    }
                    .padding(.horizontal, value: .medium)
                    .foregroundStyle(Color.ST.textSecondary)
                }

                ScrollView(.horizontal) {
                    HStack(spacing: IKPadding.medium) {
                        AddFilesMenu(selection: $newSelectedItems) {
                            STResourcesAsset.Images.plus.swiftUIImage
                                .iconSize(.large)
                                .foregroundStyle(Color.ST.primary)
                                .frame(width: 80, height: 80)
                                .background(Color.ST.background, in: .rect(cornerRadius: IKRadius.large))
                        }
                        .onChange(of: newSelectedItems) { selectedItems in
                            files = newTransferManager.addFiles(urls: selectedItems)
                        }

                        ForEach(files) { file in
                            if file.isFolder {
                                NavigationLink(value: file) {
                                    SmallThumbnailView(name: file.name) {
                                        newTransferManager.remove(file: file) {
                                            files = newTransferManager.filesAt(folderURL: nil)
                                        }
                                    }
                                }
                            } else {
                                SmallThumbnailView(url: file.url, mimeType: file.mimeType) {
                                    newTransferManager.remove(file: file) {
                                        files = newTransferManager.filesAt(folderURL: nil)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, value: .small)
                    .padding(.horizontal, value: .medium)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top, value: .medium)
            .padding(.bottom, value: .small)
            .background(Color.ST.cardBackground, in: .rect(cornerRadius: IKRadius.large))
        }
        .onAppear {
            files = newTransferManager.filesAt(folderURL: nil)
        }
    }
}

#Preview {
    NewTransferFilesCellView()
}
