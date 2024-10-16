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
    private let file: File

    public init(file: File) {
        self.file = file
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack {
                FileIconView(icon: file.icon.swiftUIImage, type: .big)
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading) {
                Text(file.fileName)
                    .foregroundStyle(Color.ST.textPrimary)
                Text(file.fileSizeInBytes.formatted(.defaultByteCount))
                    .foregroundStyle(Color.ST.textSecondary)
            }
            .font(.ST.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(value: .small)
            .background(.white)
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.ST.cardBackground
        }
        .clipShape(RoundedRectangle(cornerRadius: IKRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: IKRadius.medium)
                .stroke(Color.ST.cardBorder)
        )
    }
}

#Preview {
    LargeThumbnailView(file: PreviewHelper.sampleFile)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
