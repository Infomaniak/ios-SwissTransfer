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

    @State private var isShowingFileList = false

    private var filesSize: Int64 {
        newTransferManager.displayableFiles.map { $0.computedSize }.reduce(0, +)
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
                            "\(STResourcesStrings.Localizable.filesCount(newTransferManager.displayableFiles.count)) · \(filesSize.formatted(.defaultByteCount))"
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
                    HStack {
                        AddFilesMenuView { urls in
                            newTransferManager.addFiles(urls: urls)
                        } label: {
                            STResourcesAsset.Images.plus.swiftUIImage
                                .iconSize(.large)
                                .foregroundStyle(Color.ST.primary)
                                .frame(width: 80, height: 80)
                                .background(.white, in: .rect(cornerRadius: 16))
                        }

                        ForEach(newTransferManager.displayableFiles) { file in
                            if file.isFolder {
                                NavigationLink(value: file) {
                                    SmallThumbnailView {
                                        newTransferManager.remove(file: file)
                                    }
                                }
                            } else {
                                SmallThumbnailView(url: file.url, mimeType: file.mimeType) {
                                    newTransferManager.remove(file: file)
                                }
                            }
                        }
                    }
                    .padding(.bottom, value: .small)
                    .padding(.horizontal, value: .medium)
                }
            }
            .padding(.top, value: .medium)
            .padding(.bottom, value: .small)
            .background(Color.ST.cardBackground, in: .rect(cornerRadius: 16))
        }
        .padding(.horizontal, value: .medium)
    }
}

#Preview {
    NewTransferFilesCellView()
}
