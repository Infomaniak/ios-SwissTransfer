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
import STCore
import SwiftUI

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

public enum ThumbnailType {
    case importingFile
    case importedFile(URL)
    case folder
    case file(fileUUID: String, transferUUID: String, sourceURL: URL?)
}

public struct SmallThumbnailView: View {
    @Environment(\.displayScale) private var scale

    @ScaledMetric(wrappedValue: 0, relativeTo: .body) private var size

    private let fileType: FileType
    private let name: String?
    private let thumbnailSize: SmallThumbnailSize

    private let thumbnailType: ThumbnailType

    @State private var thumbnail: Image?

    /// Importing
    public init(size: SmallThumbnailSize) {
        name = nil
        thumbnailSize = size

        _size = ScaledMetric(wrappedValue: size.size, relativeTo: .body)
        fileType = .unknown

        thumbnailType = .importingFile
    }

    /// Imported file
    public init(url: URL, mimeType: String, size: SmallThumbnailSize) {
        name = url.lastPathComponent
        thumbnailSize = size

        _size = ScaledMetric(wrappedValue: size.size, relativeTo: .body)
        fileType = FileTypeProvider(mimeType: mimeType).fileType

        thumbnailType = .importedFile(url)
    }

    /// File
    public init(fileUI: FileUi, transferUI: TransferUi, size: SmallThumbnailSize) {
        name = fileUI.fileName
        thumbnailSize = size

        _size = ScaledMetric(wrappedValue: size.size, relativeTo: .body)
        fileType = FileTypeProvider(mimeType: fileUI.mimeType ?? "").fileType

        thumbnailType = .file(
            fileUUID: fileUI.uid,
            transferUUID: transferUI.uuid,
            sourceURL: fileUI.localURLFor(transfer: transferUI)
        )
    }

    /// Folder
    public init(name: String? = nil, size: SmallThumbnailSize) {
        self.name = name
        thumbnailSize = size

        _size = ScaledMetric(wrappedValue: size.size, relativeTo: .body)
        fileType = .folder

        thumbnailType = .folder
    }

    public var body: some View {
        ZStack {
            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
            } else {
                VStack(spacing: IKPadding.mini) {
                    FileIconView(fileType: fileType, type: .small)

                    if let name, thumbnailSize.shouldShowName {
                        Text(name)
                            .font(.ST.caption)
                            .foregroundStyle(Color.ST.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(value: .mini)
                .frame(width: size, height: size)
                .background(Color.ST.background)
                .task {
                    switch thumbnailType {
                    case .importedFile(let url):
                        thumbnail = try? await ThumbnailProvider().generateThumbnail(fileURL: url, scale: scale)
                    case .file(let fileUUID, let transferUUID, let fileURL):
                        thumbnail = await ThumbnailProvider().generateThumbnailFor(
                            fileUUID: fileUUID,
                            transferUUID: transferUUID,
                            fileURL: fileURL,
                            scale: scale
                        )
                    case .folder, .importingFile:
                        break
                    }
                }
            }
        }
        .clipShape(.rect(cornerRadius: thumbnailSize.radius))
    }
}

#Preview {
    SmallThumbnailView(url: URL(fileURLWithPath: ""), mimeType: "public.jpeg", size: .small)
    SmallThumbnailView(url: URL(fileURLWithPath: ""), mimeType: "public.jpeg", size: .medium)
}
