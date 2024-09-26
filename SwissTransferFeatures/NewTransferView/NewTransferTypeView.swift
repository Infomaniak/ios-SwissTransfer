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

    @State private var navigateToDetails = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack {
            Text(STResourcesStrings.Localizable.transferTypeTitle)
                .font(.ST.title)

            LazyVGrid(columns: columns,
                      alignment: .center,
                      spacing: 16,
                      pinnedViews: []) {
                ForEach(TransferType.allCases, id: \.rawValue) { type in
                    Button {
                        newTransferManager.transferType = type
                        navigateToDetails = true
                    } label: {
                        VStack(spacing: IKPadding.extraLarge) {
                            Text(type.title)
                                .padding(.top, 40)
                            type.icon
                        }
                        .foregroundStyle(type.foregroundColor)
                        .frame(maxWidth: .infinity)
                        .background(type.backgroundColor, in: .rect(cornerRadius: 16))
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToDetails) {
            NewTransferDetailsView()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .stNavigationBarNewTransfer()
        .stNavigationBarStyle()
    }
}

#Preview {
    NewTransferTypeView()
}
