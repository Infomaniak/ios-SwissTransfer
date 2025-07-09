/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

import InfomaniakCoreCommonUI
import InfomaniakDI
import STCore
import STResources
import SwiftUI

struct QRCodePanelButton: View {
    @LazyInjectService var injection: SwissTransferInjection
    @InjectService private var matomo: MatomoUtils

    @State private var isShowingQRCode = false

    let transfer: TransferUi
    let vertical: Bool
    let matomoCategory: MatomoUtils.EventCategory

    private var transferURL: URL? {
        let apiURLCreator = injection.sharedApiUrlCreator
        let url = apiURLCreator.shareTransferUrl(transferUUID: transfer.uuid)
        return URL(string: url)
    }

    var body: some View {
        if let transferURL {
            Button {
                isShowingQRCode = true
                matomo.track(eventWithCategory: matomoCategory, name: "showQRCode")
            } label: {
                if vertical {
                    VStack {
                        STResourcesAsset.Images.qrCode.swiftUIImage
                            .iconSize(.large)

                        Text(STResourcesStrings.Localizable.transferTypeQrCode)
                            .font(.ST.caption)
                    }
                    .frame(width: 100)
                } else {
                    Label {
                        Text(STResourcesStrings.Localizable.transferTypeQrCode)
                            .font(.ST.caption)
                    } icon: {
                        STResourcesAsset.Images.qrCode.swiftUIImage
                            .iconSize(.large)
                    }
                }
            }
            .stFloatingPanel(isPresented: $isShowingQRCode, bottomPadding: .zero) {
                QRCodePanelView(url: transferURL)
            }
        }
    }
}
