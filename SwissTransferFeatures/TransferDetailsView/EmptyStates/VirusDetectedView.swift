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

import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

struct VirusDetectedView: View {
    @Environment(\.dismiss) private var dismiss

    let transfer: TransferUi?

    var body: some View {
        IllustrationAndTextView(
            image: STResourcesAsset.Images.ghostPointingReport.swiftUIImage,
            title: STResourcesStrings.Localizable.transferVirusDetectedTitle,
            subtitle: STResourcesStrings.Localizable.transferVirusDetectedDescription,
            style: .emptyState
        )
        .padding(value: .medium)
        .scrollableEmptyState()
        .deleteLocalTransferSafeAreaButton(transfer: transfer, origin: .virusDetected)
        .appBackground()
        .stNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                ToolbarCloseButton(dismiss: dismiss)
            }
        }
        .matomoView(view: .virusDetected)
    }
}

#Preview {
    VirusDetectedView(transfer: PreviewHelper.sampleTransfer)
}
