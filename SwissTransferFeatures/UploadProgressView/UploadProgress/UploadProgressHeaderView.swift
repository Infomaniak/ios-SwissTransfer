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

struct UploadProgressHeaderView: View {
    let subtitle: AttributedString

    private var title: AttributedString {
        var result = AttributedString(STResourcesStrings.Localizable.uploadProgressTitleTemplate(
            STResourcesStrings.Localizable.uploadProgressTitleArgument
        ))

        if let highlightedRange = result.range(of: STResourcesStrings.Localizable.uploadProgressTitleArgument) {
            result[highlightedRange].backgroundColor = .ST.highlighted
        }

        return result
    }

    var body: some View {
        VStack(spacing: 32) {
            Text(title)
                .font(.ST.headline)

            Text(subtitle)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.ST.textPrimary)
    }
}

#Preview {
    UploadProgressHeaderView(subtitle: "Lorem Ipsum")
}
