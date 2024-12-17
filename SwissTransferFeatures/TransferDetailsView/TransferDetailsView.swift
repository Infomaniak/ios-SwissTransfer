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

public struct TransferDetailsView: View {
    @LazyInjectService private var injection: SwissTransferInjection
    @Environment(\.dismiss) private var dismiss

    private let transfer: TransferUi

    private var transferURL: URL? {
        let apiURLCreator = injection.sharedApiUrlCreator
        let url = apiURLCreator.shareTransferUrl(transferUUID: transfer.uuid)
        return URL(string: url)
    }

    public init(transfer: TransferUi) {
        self.transfer = transfer
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: IKPadding.large) {
                    HeaderView(
                        filesCount: transfer.files.count,
                        transferSize: transfer.sizeUploaded,
                        expiringTimestamp: transfer.expirationDateTimestamp
                    )

                    if let trimmedMessage = transfer.trimmedMessage, !trimmedMessage.isEmpty {
                        MessageView(message: trimmedMessage)
                    }

                    ContentView(transfer: transfer)
                }
                .padding(.vertical, value: .large)
                .padding(.horizontal, value: .medium)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if let transferURL {
                        Spacer()

                        ShareLink(item: transferURL) {
                            VStack {
                                STResourcesAsset.Images.share.swiftUIImage
                                    .iconSize(.large)

                                Text(STResourcesStrings.Localizable.buttonShare)
                                    .font(.ST.caption)
                            }
                            .frame(width: 100)
                        }
                    }

                    Spacer()

                    Button {} label: {
                        VStack {
                            STResourcesAsset.Images.qrCode.swiftUIImage
                                .iconSize(.large)

                            Text(STResourcesStrings.Localizable.transferTypeQrCode)
                                .font(.ST.caption)
                        }
                        .frame(width: 100)
                    }

                    Spacer()

                    Button {} label: {
                        VStack {
                            STResourcesAsset.Images.textfieldLock.swiftUIImage
                                .iconSize(.large)

                            Text(STResourcesStrings.Localizable.settingsOptionPassword)
                                .font(.ST.caption)
                        }
                        .frame(width: 100)
                    }

                    Spacer()
                }
            }
            .toolbarBackground(.visible, for: .bottomBar)
            .appBackground()
            .stNavigationBarStyle()
            .stNavigationBarFullScreen(title: transfer.name)
            .navigationDestination(for: FileUi.self) { file in
                FileListView(folder: file, transfer: transfer)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    DownloadButton(transfer: transfer)
                }
            }
        }
        .environment(\.dismissModal) { dismiss() }
    }
}

#Preview {
    TransferDetailsView(transfer: PreviewHelper.sampleTransfer)
}
