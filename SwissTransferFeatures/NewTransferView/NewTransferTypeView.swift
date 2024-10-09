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

import InfomaniakCoreUI
import STResources
import SwiftUI
import SwissTransferCore

struct NewTransferTypeView: View {
    @EnvironmentObject private var newTransferManager: NewTransferManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(STResourcesStrings.Localizable.transferTypeTitle)
                .font(.ST.callout)
                .foregroundStyle(Color.ST.textPrimary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal) {
                HStack {
                    ForEach(TransferType.allCases, id: \.rawValue) { type in
                        TransferTypeCell(type: type, isSelected: newTransferManager.transferType == type)
                            .onTapGesture {
                                withAnimation {
                                    newTransferManager.transferType = type
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 1)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    NewTransferTypeView()
}
