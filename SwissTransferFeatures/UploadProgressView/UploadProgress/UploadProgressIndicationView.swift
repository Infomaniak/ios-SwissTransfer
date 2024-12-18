//
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

struct UploadProgressIndicationView: View {
    @StateObject private var reachabilityObserver = ReachabilityObserver()

    let completedBytes: Int64
    let totalBytes: Int64

    private var percentCompleted: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(completedBytes) / Double(totalBytes)
    }

    private var isOnline: Bool {
        let networkStatus = reachabilityObserver.networkStatus
        return networkStatus == .wifi || networkStatus == .cellular
    }

    var body: some View {
        VStack(spacing: IKPadding.small) {
            Text(STResourcesStrings.Localizable.uploadProgressIndication)
                .font(.ST.title2)
                .foregroundStyle(Color.ST.textPrimary)

            Group {
                if isOnline {
                    HStack(spacing: IKPadding.extraSmall) {
                        Text(percentCompleted, format: .defaultPercent)
                        Text("-")
                        HStack(spacing: 2) {
                            Text(completedBytes, format: .progressByteCount)
                            Text("/")
                            Text(totalBytes, format: .progressByteCount)
                        }
                    }
                    .foregroundStyle(Color.ST.textSecondary)
                } else {
                    Label {
                        Text(STResourcesStrings.Localizable.networkUnavailable)
                    } icon: {
                        STResourcesAsset.Images.antennaSignalSlash.swiftUIImage
                            .iconSize(.medium)
                    }
                    .labelStyle(.ikLabel)
                    .foregroundStyle(Color.ST.warning)
                }
            }
            .font(.ST.caption)
        }
    }
}

#Preview {
    UploadProgressIndicationView(completedBytes: 12, totalBytes: 42)
}
