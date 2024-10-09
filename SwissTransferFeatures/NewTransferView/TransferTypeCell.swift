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

import SwiftUI
import SwissTransferCoreUI

struct TransferTypeCell: View {
    let type: TransferType
    let isSelected: Bool

    var body: some View {
        Label {
            Text(type.title)
                .font(.ST.callout)
                .foregroundStyle(isSelected ? Color.ST.primary : Color.ST.textSecondary)
        } icon: {
            type.icon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(isSelected ? Color.ST.primary : Color.ST.textSecondary)
        }
        .labelStyle(.horizontal)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.ST.primary : Color.ST.cardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        TransferTypeCell(type: .link, isSelected: true)
        TransferTypeCell(type: .link, isSelected: false)
    }
}
