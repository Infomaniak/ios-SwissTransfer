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

struct NewTransferTypeView: View {
    @Binding var transferType: TransferType

    var body: some View {
        VStack(alignment: .leading, spacing: IKPadding.medium) {
            Text(STResourcesStrings.Localizable.transferTypeTitle)
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textPrimary)
                .padding(.horizontal, value: .medium)

            ScrollView(.horizontal) {
                HStack {
                    ForEach(TransferType.allCases, id: \.name) { type in
                        Button {
                            withAnimation {
                                transferType = type
                            }
                        } label: {
                            TransferTypeCell(type: type, isSelected: transferType == type)
                        }
                    }
                }
                .padding(.horizontal, value: .medium)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    NewTransferTypeView(transferType: .constant(.qrcode))
}
