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
import SwissTransferCore
import SwissTransferCoreUI

struct LegacyToolbarSpacing: View {
    var body: some View {
        if #unavailable(iOS 26.0) {
            Spacer()
        }
    }
}

struct ShareTransferToolbarModifier: ViewModifier {
    @LazyInjectService private var injection: SwissTransferInjection

    @EnvironmentObject private var multipleSelectionManager: MultipleSelectionManager

    @State private var isShowingPassword = false

    let transfer: TransferUi
    let matomoCategory: MatomoCategory

    private var transferURL: URL? {
        let apiURLCreator = injection.sharedApiUrlCreator
        let url = apiURLCreator.shareTransferUrl(transferUUID: transfer.uuid)
        return URL(string: url)
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                if !multipleSelectionManager.isEnabled {
                    ToolbarItemGroup(placement: .bottomBar) {
                        QRCodePanelButton(transfer: transfer, matomoCategory: .sentTransfer)

                        LegacyToolbarSpacing()

                        if let transferURL {
                            ShareLink(item: transferURL) {
                                Label {
                                    Text(STResourcesStrings.Localizable.buttonShare)
                                } icon: {
                                    STResourcesAsset.Images.squareArrowUp.swiftUIImage
                                }
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                @InjectService var matomo: MatomoUtils
                                matomo.track(eventWithCategory: matomoCategory, name: .share)
                            })

                            LegacyToolbarSpacing()
                        }
                    }

                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(.fixed, placement: .bottomBar)
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        if let password = transfer.password, !password.isEmpty, transfer.direction == .sent {
                            Button {
                                isShowingPassword = true
                            } label: {
                                Label {
                                    Text(STResourcesStrings.Localizable.settingsOptionPassword)
                                } icon: {
                                    STResourcesAsset.Images.textfieldLock.swiftUIImage
                                }
                            }
                            .stFloatingPanel(isPresented: $isShowingPassword, bottomPadding: .zero) {
                                PasswordPanelView(password: password, matomoCategory: matomoCategory)
                            }

                            LegacyToolbarSpacing()
                        }
                    }
                }

                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    DownloadButton(transfer: transfer, matomoCategory: .receivedTransfer)
                }
            }
    }
}

public extension View {
    func shareTransferToolbar(transfer: TransferUi, matomoCategory: MatomoCategory) -> some View {
        modifier(ShareTransferToolbarModifier(transfer: transfer, matomoCategory: matomoCategory))
    }
}
