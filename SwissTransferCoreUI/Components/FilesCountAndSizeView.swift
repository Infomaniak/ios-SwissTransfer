/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

public struct FilesCountAndSizeView: View {
    private let count: Int
    private let size: Int64

    private var filesCountText: Text {
        if count > Constants.maxFileCount {
            return Text(STResourcesStrings.Localizable.fileCountOverDisplayOnly(count, Constants.maxFileCount))
                .accessibilityLabel(
                    Text(STResourcesStrings.Localizable.fileCountOverTtsFriendly(count, Constants.maxFileCount))
                )
        }
        return Text(STResourcesStrings.Localizable.filesCount(count))
    }

    private var filesCountColor: Color {
        return count > Constants.maxFileCount ? Color.ST.error : Color.ST.textSecondary
    }

    private var filesSizeText: Text {
        if size > Constants.maxFileSize {
            let sizeFormatted = size.formatted(.defaultByteCount)
            let maxSizeFormatted = Constants.maxFileSize.formatted(.defaultByteCount)
            return Text(STResourcesStrings.Localizable.fileSizeOverDisplayOnly(sizeFormatted, maxSizeFormatted))
                .accessibilityLabel(
                    Text(STResourcesStrings.Localizable.fileSizeOverTtsFriendly(sizeFormatted, maxSizeFormatted))
                )
        }
        return Text(STResourcesStrings.Localizable.transferSpaceLeft((Constants.maxFileSize - size).formatted(.defaultByteCount)))
    }

    private var filesSizeColor: Color {
        return size > Constants.maxFileSize ? Color.ST.error : Color.ST.textSecondary
    }

    public init(count: Int, size: Int64) {
        self.size = size
        self.count = count
    }

    public var body: some View {
        SeparatedItemsView {
            filesCountText
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(filesCountColor)
        } rhs: {
            filesSizeText
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(filesSizeColor)
        }
    }
}

#Preview {
    FilesCountAndSizeView(count: 15, size: 200_000)
}
