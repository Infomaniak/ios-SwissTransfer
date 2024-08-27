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
import STCore
import SwiftUI
import SwissTransferCore

public struct TransferDetailsView: View {
    private let transfer: Transfer

    public init(transfer: Transfer) {
        self.transfer = transfer
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: IKPadding.large) {
                HeaderView(transfer: transfer)

                MessageView(message: transfer.castedContainer.message)

                ContentView(files: transfer.castedContainer.files)
            }
            .padding(.vertical, value: .large)
            .padding(.horizontal, value: .medium)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(transfer.name)
                    .font(.ST.title2)
                    .foregroundStyle(.white)
            }
        }
        .stNavigationBarStyle()
    }
}

#Preview {
    TransferDetailsView(transfer: PreviewHelper.sampleTransfer)
}
