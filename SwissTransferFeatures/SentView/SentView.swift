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
import SwissTransferCoreUI

public struct SentView: View {
    private let isEmpty: Bool

    public init(isEmpty: Bool) {
        self.isEmpty = isEmpty
    }

    public var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    SentEmptyView()
                } else {
                    SentListView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) { // <3>
                    STResourcesAsset.Images.logo.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(STResourcesAsset.Colors.greenDark.swiftUIColor, for: .navigationBar)
        }
    }
}

#Preview {
    SentView(isEmpty: true)
}
