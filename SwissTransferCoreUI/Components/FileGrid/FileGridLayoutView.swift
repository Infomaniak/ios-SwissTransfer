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

import DesignSystem
import InfomaniakCoreSwiftUI
import SwiftUI

public struct FileGridLayoutView<Content: View>: View {
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: IKPadding.medium),
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: IKPadding.medium)
    ]

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: IKPadding.medium, pinnedViews: []) {
            content
        }
    }
}

#Preview {
    FileGridLayoutView {
        Text("Hello")
    }
}
