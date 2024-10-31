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
import SwissTransferCore
import SwissTransferCoreUI

struct SuccessfulLinkTransferView: View {
    private static let qrCodeSize: CGFloat = 160

    let type: TransferType
    let url: URL
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            STResourcesAsset.Images.beers.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Self.qrCodeSize)

            Text(type.successTitle)
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)

            QRCodeView(url: url)
                .frame(width: Self.qrCodeSize, height: Self.qrCodeSize)

            if type != .qrcode {
                Text(STResourcesStrings.Localizable.uploadSuccessLinkDescription)
                    .font(.ST.body)
                    .foregroundStyle(Color.ST.textSecondary)
                    .frame(maxWidth: LargeEmptyStateView.textMaxWidth)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, value: .medium)
        .padding(.vertical, value: .large)
        .scrollableEmptyState()
        .safeAreaButtons {
            HStack(spacing: IKPadding.medium) {
                ShareLink(item: url) {
                    Label {
                        Text(STResourcesStrings.Localizable.buttonShare)
                    } icon: {
                        STResourcesAsset.Images.personBadgeShare.swiftUIImage
                    }
                    .labelStyle(.verticalButton)
                }

                CopyToClipboardButton(url: url)
            }
            .buttonStyle(.ikBordered)
            .frame(maxWidth: IKButtonConstants.maxWidth)

            Button(action: dismiss) {
                Text(STResourcesStrings.Localizable.buttonFinished)
            }
            .buttonStyle(.ikBorderedProminent)
        }
    }

    private func copyLinkToClipboard() {
        UIPasteboard.general.string = url.absoluteString
    }
}

#Preview("QR Code") {
    SuccessfulLinkTransferView(type: .qrcode, url: URL(string: "https://www.infomaniak.com")!) {}
}

#Preview("Link") {
    SuccessfulLinkTransferView(type: .link, url: URL(string: "https://www.infomaniak.com")!) {}
}
