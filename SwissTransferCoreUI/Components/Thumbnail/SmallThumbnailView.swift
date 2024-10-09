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

import STResources
import SwiftUI
import SwissTransferCore

public struct SmallThumbnailView: View {
    @ScaledMetric(relativeTo: .body) private var size = 48

    private let url: URL?
    private let removeAction: (() -> Void)?

    @State private var icon: Image
    @State private var thumbnail: Image?
    @State private var cornerRadius: CGFloat = 8

    /// File init
    public init(url: URL?, mimeType: String, removeAction: (() -> Void)? = nil) {
        self.url = url
        self.removeAction = removeAction

        if removeAction != nil {
            _size = ScaledMetric(wrappedValue: 80, relativeTo: .body)
            cornerRadius = 16
        }

        icon = FileHelper(type: mimeType).icon.swiftUIImage
    }

    /// Folder init
    public init(removeAction: (() -> Void)? = nil) {
        url = nil
        self.removeAction = removeAction

        if removeAction != nil {
            _size = ScaledMetric(wrappedValue: 80, relativeTo: .body)
            cornerRadius = 16
        }

        icon = STResourcesAsset.Images.folder.swiftUIImage
    }

    public var body: some View {
        ZStack {
            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(.rect(cornerRadius: cornerRadius))
            } else {
                FileIconView(icon: icon, type: .small)
                    .frame(width: size, height: size)
                    .background(Color.ST.background, in: .rect(cornerRadius: IKRadius.medium))
                    .onAppear {
                        ThumbnailGenerator.generate(for: url, cgSize: CGSize(width: size, height: size)) { thumbnail = $0 }
                    }
            }

            if let removeAction {
                Button {
                    removeAction()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 8, height: 8)
                        .padding(value: .small)
                        .background(.black.opacity(0.5), in: .circle)
                }
                .padding(value: .small)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
    }
}

#Preview {
    SmallThumbnailView(url: URL(fileURLWithPath: ""), mimeType: "public.jpeg")
}
