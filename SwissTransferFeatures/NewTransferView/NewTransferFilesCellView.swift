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
import InfomaniakCoreSwiftUI
import OSLog
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct NewTransferFilesCellView: View {
    @EnvironmentObject private var newTransferFileManager: NewTransferFileManager

    @State private var selectedItems = [ImportedItem]()
    @Binding var importFilesTasks: [ImportTask]

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Text(STResourcesStrings.Localizable.myFilesTitle)
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textPrimary)

            VStack(alignment: .leading, spacing: IKPadding.medium) {
                HStack {
                    FilesCountAndSizeView(
                        count: newTransferFileManager.filesCount + newTransferFileManager.importedItems.count,
                        size: newTransferFileManager.files.filesSize()
                    )
                    .font(.ST.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    STResourcesAsset.Images.chevronRight.swiftUIImage
                        .iconSize(.medium)
                }
                .padding(.horizontal, value: .medium)
                .foregroundStyle(Color.ST.textSecondary)

                ScrollView(.horizontal) {
                    HStack(spacing: IKPadding.medium) {
                        AddFilesMenu(
                            selection: $selectedItems,
                            maxSelectionCount: Constants.maxFileCount - newTransferFileManager.filesCount,
                            sizeExceeded: newTransferFileManager.files.filesSize() >= Constants.maxFileSize,
                            matomoCategory: .importFileFromNewTransfer
                        ) {
                            STResourcesAsset.Images.plus.swiftUIImage
                                .iconSize(.large)
                                .foregroundStyle(Color.ST.primary)
                                .frame(width: 80, height: 80)
                                .background(Color.ST.background, in: .rect(cornerRadius: IKRadius.large))
                        }
                        .onAppear { addInitialItems() }
                        .onChange(of: selectedItems, perform: addItems)

                        ForEach(newTransferFileManager.importedItems) { _ in
                            SmallThumbnailView(size: .medium)
                                .importingItem(controlSize: .small)
                        }

                        ForEach(newTransferFileManager.files) { file in
                            if file.isFolder {
                                NavigationLink(value: file) {
                                    SmallThumbnailView(name: file.fileName, size: .medium)
                                }
                            } else {
                                NavigationLink(value: TransferableRootFolder()) {
                                    SmallThumbnailView(
                                        url: file.localURL,
                                        mimeType: file.mimeType ?? "",
                                        size: .medium
                                    )
                                }
                            }
                        }
                    }
                    .padding(.bottom, value: .mini)
                    .padding(.horizontal, value: .medium)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top, value: .medium)
            .padding(.bottom, value: .mini)
            .background {
                NavigationLink(value: TransferableRootFolder()) {
                    Color.ST.cardBackground
                        .clipShape(RoundedRectangle(cornerRadius: IKRadius.large))
                }
            }
        }
    }

    private func addInitialItems() {
        guard !newTransferFileManager.initialImportedItems.isEmpty else { return }
        addItems(newTransferFileManager.initialImportedItems)
        newTransferFileManager.initialImportedItems = []
    }

    private func addItems(_ items: [ImportedItem] = []) {
        let id = ImportTask.taskIdFor(items: items)
        guard !importFilesTasks.contains(where: { $0.id == id }) else { return }
        let task = Task {
            _ = await newTransferFileManager.addItems(items)
        }
        importFilesTasks.append(ImportTask(id: id, task: task))
    }
}

#Preview {
    NewTransferFilesCellView(importFilesTasks: .constant([]))
}
