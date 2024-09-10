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
import STResources
import SwiftUI
import SwissTransferCore

public struct LargeThumbnailView: View {
    private let fileName: String
    private let fileSize: Int64
    private let url: URL?

    private let removeAction: (() -> Void)?

    private let icon: Image
    @State private var largeThumbnail: Image?

    public init(fileName: String, fileSize: Int64, url: URL?, mimeType: String, removeAction: (() -> Void)? = nil) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.url = url
        self.removeAction = removeAction

        icon = FileHelper(type: mimeType).icon.swiftUIImage
    }

    public init(folderName: String, folderSize: Int64, removeAction: (() -> Void)? = nil) {
        fileName = folderName
        fileSize = folderSize
        url = nil
        self.removeAction = removeAction

        icon = STResourcesAsset.Images.folder.swiftUIImage
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack {
                if let largeThumbnail {
                    largeThumbnail
                        .resizable()
                        .scaledToFill()
                } else {
                    FileIconView(icon: icon, type: .big)
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading) {
                Text(fileName)
                    .foregroundStyle(Color.ST.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(fileSize.formatted(.defaultByteCount))
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .font(.ST.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(value: .small)
            .background(Color.ST.background)
        }
        .overlay {
            if let removeAction {
                Button {
                    removeAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
                .padding(value: .small)
                .background(.black.opacity(0.5), in: .circle)
                .padding(value: .small)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.ST.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: IKRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: IKRadius.medium)
                .stroke(Color.ST.cardBorder)
        )
        .onAppear {
            ThumbnailGenerator.generate(for: url, isLarge: true) { largeThumbnail = $0 }
        }
    }
}

#Preview {
    VStack {
        LargeThumbnailView(fileName: "Titre", fileSize: 8561, url: nil, mimeType: "public.jpeg")
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        LargeThumbnailView(fileName: "Titre", fileSize: 8561, url: nil, mimeType: "public.jpeg") {}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
