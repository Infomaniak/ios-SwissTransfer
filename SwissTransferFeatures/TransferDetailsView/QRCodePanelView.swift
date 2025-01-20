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
import STResources
import SwiftUI
import SwissTransferCoreUI

struct QRCodePanelView: View {
    @Environment(\.dismiss) private var dismiss

    private static let qrCodeSize: CGFloat = 180

    let url: URL

    var body: some View {
        VStack(spacing: IKPadding.large) {
            Text(STResourcesStrings.Localizable.shareQrCodeTitle)
                .font(.ST.headline)
                .foregroundStyle(Color.ST.textPrimary)

            Text(STResourcesStrings.Localizable.shareQrCodeDescription)
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)
                .multilineTextAlignment(.center)

            QRCodeView(url: url)
                .frame(width: Self.qrCodeSize, height: Self.qrCodeSize)
                .padding(.vertical, 32)

            BottomButtonsView {
                Button {
                    dismiss()
                } label: {
                    Text(STResourcesStrings.Localizable.contentDescriptionButtonClose)
                        .font(.ST.headline)
                }
                .buttonStyle(.ikBorderedProminent)
            }
        }
        .padding(.horizontal, value: .medium)
        .padding(.top, value: .medium)
    }
}

#Preview {
    QRCodePanelView(url: URL(string: "")!)
}
