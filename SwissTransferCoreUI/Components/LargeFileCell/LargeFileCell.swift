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

    private let action: (any LargeFileCellAction)?
    private let fileType: FileType

    public init(file: (any DisplayableFile)? = nil, transferUUID: String? = nil, action: (any LargeFileCellAction)? = nil) {
        self.file = file
        self.transferUUID = transferUUID
        self.action = action

        if file?.isFolder == true {
            fileType = .folder
        } else {
            fileType = FileTypeProvider(mimeType: file?.mimeType ?? "").fileType
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FileIconView(fileType: fileType, type: .large)
                .opacity(largeThumbnail == nil ? 1 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.ST.cardBackground)
                .task {
                    await generateThumbnail()
                }
                .overlay {
                    if let largeThumbnail {
                        largeThumbnail
                            .resizable()
                            .scaledToFill()
                    }
                }
                .clipped()

            VStack(alignment: .leading, spacing: 0) {
                Text(file?.fileName ?? "-")
                    .foregroundStyle(Color.ST.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text((file?.fileSize ?? 0).formatted(.defaultByteCount))
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .font(.ST.callout)
            .padding(value: .mini)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.ST.background)
        }
        .aspectRatio(164 / 152, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: IKRadius.medium)
                .stroke(Color.ST.cardBorder)
        )
        .overlay(alignment: .topTrailing) {
            if let action,
               let file {
                Button {
                    action(file: file)
                } label: {
                    action.icon(for: file, transferUUID: transferUUID)
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 8, height: 8)
                        .padding(value: .mini)
                        .background(.black.opacity(0.5), in: .circle)
                        .padding(value: .mini)
                }
            }
        }
    }

    private func generateThumbnail() async {
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

#Preview {
    VStack(spacing: 32) {
        LargeFileCell(file: PreviewHelper.sampleFile, transferUUID: nil)
            .frame(width: 164, height: 152)

        let removeAction = RemoveFileAction { _ in }
        LargeFileCell(file: PreviewHelper.sampleFile, transferUUID: nil, action: removeAction)
            .frame(width: 164, height: 152)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var di = PreviewThumbnailProvider_TargetAssembly()
    LargeFileCell(file: PreviewHelper.sampleFile, transferUUID: nil)
        .frame(maxWidth: 164)
        .frame(height: 152)
}
