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

import InfomaniakDI
import STCore
import STResources
import SwiftUI

struct ShareTransferModifier: ViewModifier {
    @LazyInjectService private var injection: SwissTransferInjection
    let transfer: TransferUi

    @State private var isShowingQRCode = false
    @State private var isShowingPassword = false

    private var transferURL: URL? {
        let apiURLCreator = injection.sharedApiUrlCreator
        let url = apiURLCreator.shareTransferUrl(transferUUID: transfer.uuid)
        return URL(string: url)
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if let transferURL {
                        Spacer()

                        ShareLink(item: transferURL) {
                            VStack {
                                STResourcesAsset.Images.squareArrowUp.swiftUIImage
                                    .iconSize(.large)

                                Text(STResourcesStrings.Localizable.buttonShare)
                                    .font(.ST.caption)
                            }
                            .frame(width: 100)
                        }

                        Spacer()

                        Button {
                            isShowingQRCode = true
                        } label: {
                            VStack {
                                STResourcesAsset.Images.qrCode.swiftUIImage
                                    .iconSize(.large)

                                Text(STResourcesStrings.Localizable.transferTypeQrCode)
                                    .font(.ST.caption)
                            }
                            .frame(width: 100)
                        }
                        .floatingPanel(isPresented: $isShowingQRCode, bottomPadding: .zero) {
                            QRCodePanelView(url: transferURL)
                        }
                    }

                    Spacer()

                    if let password = transfer.password, !password.isEmpty {
                        Button {
                            isShowingPassword = true
                        } label: {
                            VStack {
                                STResourcesAsset.Images.textfieldLock.swiftUIImage
                                    .iconSize(.large)

                                Text(STResourcesStrings.Localizable.settingsOptionPassword)
                                    .font(.ST.caption)
                            }
                            .frame(width: 100)
                        }
                        .floatingPanel(isPresented: $isShowingPassword, bottomPadding: .zero) {
                            PasswordPanelView(password: password)
                        }

                        Spacer()
                    }
                }
            }
    }
}

public extension View {
    func shareTransferToolbar(transfer: TransferUi) -> some View {
        modifier(ShareTransferModifier(transfer: transfer))
    }
}
