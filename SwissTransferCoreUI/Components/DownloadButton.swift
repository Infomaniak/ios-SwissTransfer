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

import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import OSLog
import STCore
import STResources
import SwiftUI
import SwissTransferCore

public struct DownloadButton: View {
    @EnvironmentObject private var downloadManager: DownloadManager
    @EnvironmentObject private var multipleSelectionManager: MultipleSelectionManager

    let transfer: TransferUi
    let matomoCategory: MatomoCategory

    public init(transfer: TransferUi, matomoCategory: MatomoCategory) {
        self.transfer = transfer
        self.matomoCategory = matomoCategory
    }

    public var body: some View {
        Button {
            downloadManager.startOrCancelDownload(
                transfer: transfer,
                files: Array(multipleSelectionManager.selectedItems),
                matomoCategory: matomoCategory
            )
        } label: {
            Label {
                Text(STResourcesStrings.Localizable.buttonDownload)
            } icon: {
                STResourcesAsset.Images.arrowDownLine.swiftUIImage
            }
        }
    }
}
