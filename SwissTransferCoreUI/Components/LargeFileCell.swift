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
import InfomaniakDI
import STCore
import SwiftUI
import SwissTransferCore

public struct LargeFileCell: View {
    @LazyInjectService private var thumbnailProvider: ThumbnailProvidable

    @Environment(\.displayScale) private var scale

    @State private var largeThumbnail: Image?

    private let file: (any DisplayableFile)?
    private let transferUUID: String?

    private let removeAction: RemoveFileAction?
    private let fileType: FileType

    public init(file: (any DisplayableFile)? = nil, transferUUID: String? = nil, removeAction: RemoveFileAction? = nil) {
        self.file = file
        self.transferUUID = transferUUID
        self.removeAction = removeAction

        if file?.isFolder == true {
            fileType = .folder
        } else {
            fileType = FileTypeProvider(mimeType: file?.mimeType ?? "").fileType
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { _ in
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
                    if let transferUUID,
                       let file,
                       let localURL = file.localURLFor(transferUUID: transferUUID) {
                        largeThumbnail = await thumbnailProvider.generateThumbnailFor(
                            fileUUID: file.uid,
                            transferUUID: transferUUID,
                            fileURL: localURL,
                            scale: scale
                        )
                    } else if let localURL = file?.localURLFor(transferUUID: "") {
                        largeThumbnail = try? await thumbnailProvider.generateThumbnail(fileURL: localURL, scale: scale)
                    }
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 0) {
                Text(file?.fileName ?? "-")
                    .foregroundStyle(Color.ST.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text((file?.fileSize ?? 0).formatted(.defaultByteCount))
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .font(.ST.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(value: .mini)
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
                        .padding(value: .mini)
                        .background(.black.opacity(0.5), in: .circle)
                        .padding(value: .mini)
                }
            }
        }
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
        LargeFileCell(file: PreviewHelper.sampleFile, transferUUID: nil)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        let removeAction = RemoveFileAction { _ in }
        LargeFileCell(file: PreviewHelper.sampleFile, transferUUID: nil, removeAction: removeAction)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var di = PreviewThumbnailProvider_TargetAssembly()
    LargeFileCell(file: PreviewHelper.sampleFile, transferUUID: nil)
}
