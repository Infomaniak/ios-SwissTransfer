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

import DesignSystem
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct UploadSuccessQRCodeView: View {
    private static let qrCodeSize: CGFloat = 160

    @LazyInjectService private var injection: SwissTransferInjection

    @Environment(\.dismiss) private var dismiss

    @State private var isShowingShareTipSheet = false

    let type: TransferType
    let transferUUID: String

    private var transferURL: URL? {
        let apiURLCreator = injection.sharedApiUrlCreator
        let url = apiURLCreator.shareTransferUrl(transferUUID: transferUUID)
        return URL(string: url)
    }

    var body: some View {
        VStack(spacing: IKPadding.huge) {
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

            Text(STResourcesStrings.Localizable.uploadSuccessLinkDescription)
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)
                .frame(maxWidth: IllustrationAndTextView.Style.emptyState.textMaxWidth)
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
                    .simultaneousGesture(TapGesture().onEnded {
                        @InjectService var matomo: MatomoUtils
                        matomo.track(eventWithCategory: .newTransfer, name: "share")
                    })

                    CopyToClipboardButton(item: transferURL, labelStyle: .verticalButton, matomoCategory: .newTransfer)
                }
                .buttonStyle(.ikBordered)
                .frame(maxWidth: IKButtonConstants.maxWidth)
            }

            Button(action: dismiss.callAsFunction) {
                Text(STResourcesStrings.Localizable.buttonFinished)
            }
            .buttonStyle(.ikBorderedProminent)
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    isShowingShareTipSheet = true
                }
            }
        }
        .stDiscoveryPresenter(isPresented: $isShowingShareTipSheet, bottomPadding: 0) {
            ScreenshotQrBottomSheetView()
        }
    }
}

#Preview {
    UploadSuccessQRCodeView(type: .link, transferUUID: PreviewHelper.sampleTransfer.uuid)
}
