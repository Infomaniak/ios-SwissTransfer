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
import SwiftUI

public struct SmallMoreItemsThumbnailView: View {
    @ScaledMetric(relativeTo: .body) private var size = 48

    let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        Text("+\(count)")
            .font(.ST.body)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(Color.ST.onSecondary)
            .padding(value: .micro)
            .frame(width: size, height: size)
            .background(
                Color.ST.secondary
                    .clipShape(RoundedRectangle(cornerRadius: IKRadius.medium))
            )
    }
}

#Preview {
    HStack {
        SmallMoreItemsThumbnailView(count: 1)
        SmallMoreItemsThumbnailView(count: 10)
        SmallMoreItemsThumbnailView(count: 100)
        SmallMoreItemsThumbnailView(count: 1000)
    }
}
