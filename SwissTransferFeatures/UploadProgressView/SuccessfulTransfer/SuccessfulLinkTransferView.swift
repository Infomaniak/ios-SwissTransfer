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
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct SuccessfulLinkTransferView: View {
    private static let qrCodeSize: CGFloat = 160

    @LazyInjectService private var injection: SwissTransferInjection

    let type: TransferType
    let transferUUID: String
    let dismiss: () -> Void

    private var transferURL: URL? {
        let apiURLCreator = injection.sharedApiUrlCreator
        let url = apiURLCreator.shareTransferUrl(transferUUID: transferUUID)
        return URL(string: url)
    }

    var body: some View {
        VStack(spacing: 32) {
            STResourcesAsset.Images.beers.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: Self.qrCodeSize)

            Text(type.successTitle)
                .font(.ST.title)
                .foregroundStyle(Color.ST.textPrimary)

            if let transferURL {
                QRCodeView(url: transferURL)
                    .frame(width: Self.qrCodeSize, height: Self.qrCodeSize)
            }

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
            if let transferURL {
                HStack(spacing: IKPadding.medium) {
                    ShareLink(item: transferURL) {
                        Label {
                            Text(STResourcesStrings.Localizable.buttonShare)
                        } icon: {
                            STResourcesAsset.Images.personBadgeShare.swiftUIImage
                        }
                        .labelStyle(.verticalButton)
                    }
                    CopyToClipboardButton(url: transferURL)
                }
                .buttonStyle(.ikBordered)
                .frame(maxWidth: IKButtonConstants.maxWidth)
            }

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
