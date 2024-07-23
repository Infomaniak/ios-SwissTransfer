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

struct SentEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Notre histoire commence ici")
                .font(.specificLargeHeaderMedium)
                .foregroundStyle(STResourcesAsset.Colors.greyOrca.swiftUIColor)
                .multilineTextAlignment(.center)
            Text("Fais ton premier transfert !")
                .font(.bodyRegular)
                .foregroundStyle(STResourcesAsset.Colors.greyElephant.swiftUIColor)
            FirstTransferButton(style: .big) {
                // Transfer
            }
            .padding(.top, 24)
        }
    }
}

#Preview {
    SentEmptyView()
}
