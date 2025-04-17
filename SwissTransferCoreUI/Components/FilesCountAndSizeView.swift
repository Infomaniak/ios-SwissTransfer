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

    private var filesCountText: String {
        if count > Constants.maxFileCount {
            return STResourcesStrings.Localizable.fileCountOverDisplayOnly(count, Constants.maxFileCount)
        }
        return STResourcesStrings.Localizable.filesCount(count)
    }

    private var filesCountColor: Color {
        return count > Constants.maxFileCount ? Color.ST.error : Color.ST.textSecondary
    }

    public init(count: Int, size: Int64) {
        self.size = size
        self.count = count
    }

    public var body: some View {
        SeparatedItemsView {
            Text(filesCountText)
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(filesCountColor)
        } rhs: {
            Text(size, format: .defaultByteCount)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
    }
}

#Preview {
    FilesCountAndSizeView(count: 15, size: 200_000)
}
