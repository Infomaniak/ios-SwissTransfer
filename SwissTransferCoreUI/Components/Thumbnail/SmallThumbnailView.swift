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

public enum SmallThumbnailSize {
    case small
    case medium

    var size: CGFloat {
        switch self {
        case .small:
            return 48
        case .medium:
            return 80
        }
    }

    var radius: CGFloat {
        switch self {
        case .small:
            return IKRadius.medium
        case .medium:
            return IKRadius.large
        }
    }

    var shouldShowName: Bool {
        switch self {
        case .small:
            return false
        case .medium:
            return true
        }
    }
}

public struct SmallThumbnailView: View {
    @Environment(\.displayScale) private var scale

    @ScaledMetric(wrappedValue: 0, relativeTo: .body) private var size

    private let url: URL?
    private let name: String?
    private let thumbnailSize: SmallThumbnailSize

    @State private var icon: Image
    @State private var thumbnail: Image?

    /// File init
    public init(url: URL?, mimeType: String, size: SmallThumbnailSize) {
        self.url = url
        name = url?.lastPathComponent
        thumbnailSize = size

        _size = ScaledMetric(wrappedValue: size.size, relativeTo: .body)
        icon = FileHelper(type: mimeType).icon.swiftUIImage
    }

    /// Folder init
    public init(name: String? = nil, size: SmallThumbnailSize) {
        url = nil
        self.name = name
        thumbnailSize = size

        _size = ScaledMetric(wrappedValue: 80, relativeTo: .body)
        icon = STResourcesAsset.Images.folder.swiftUIImage
    }

    public var body: some View {
        ZStack {
            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
            } else {
                VStack(spacing: IKPadding.small) {
                    FileIconView(icon: icon, type: .small)

                    if let name, thumbnailSize.shouldShowName {
                        Text(name)
                            .font(.ST.caption)
                            .foregroundStyle(Color.ST.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(value: .small)
                .background(Color.ST.background)
                .task {
                    thumbnail = await ThumbnailGenerator.generate(
                        for: url,
                        scale: scale,
                        cgSize: CGSize(width: size, height: size)
                    )
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: thumbnailSize.radius))
    }
}

#Preview {
    SmallThumbnailView(url: URL(fileURLWithPath: ""), mimeType: "public.jpeg", size: .small)
    SmallThumbnailView(url: URL(fileURLWithPath: ""), mimeType: "public.jpeg", size: .medium)
}
