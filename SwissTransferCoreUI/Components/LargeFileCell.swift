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
import STCore
import SwiftUI
import SwissTransferCore

public struct LargeFileCell: View {
    @Environment(\.displayScale) private var scale

    @State private var largeThumbnail: Image?

    private let file: any DisplayableFile
    private let container: String?

    private let removeAction: RemoveFileAction?
    private let fileType: FileType

    public init(file: any DisplayableFile, container: String?, removeAction: RemoveFileAction? = nil) {
        self.file = file
        self.container = container
        self.removeAction = removeAction

        if file.isFolder {
            fileType = .folder
        } else {
            fileType = FileTypeProvider(mimeType: file.mimeType ?? "").fileType
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { reader in
                ZStack {
                    if let largeThumbnail {
                        largeThumbnail
                            .resizable()
                            .scaledToFill()
                    } else {
                        FileIconView(fileType: fileType, type: .large)
                    }
                }
                .frame(height: 96)
                .frame(maxWidth: .infinity)
                .clipped()
                .task {
                    guard let container else { return }
                    largeThumbnail = await ThumbnailGenerator.generate(
                        for: file.localURL(in: container),
                        scale: scale,
                        cgSize: reader.size
                    )
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 0) {
                Text(file.fileName)
                    .foregroundStyle(Color.ST.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(file.fileSize.formatted(.defaultByteCount))
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .font(.ST.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(value: .small)
            .background(Color.ST.background)
        }
        .overlay(alignment: .topTrailing) {
            if let removeAction {
                Button {
                    guard let transferableFile = file as? TransferableFile else { return }
                    removeAction(file: transferableFile)
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 8, height: 8)
                        .padding(value: .small)
                        .background(.black.opacity(0.5), in: .circle)
                        .padding(value: .small)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.ST.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: IKRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: IKRadius.medium)
                .stroke(Color.ST.cardBorder)
        )
    }
}

#Preview {
    VStack {
        LargeFileCell(file: PreviewHelper.sampleFile, container: nil)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        let removeAction = RemoveFileAction { _ in }
        LargeFileCell(file: PreviewHelper.sampleFile, container: nil, removeAction: removeAction)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
