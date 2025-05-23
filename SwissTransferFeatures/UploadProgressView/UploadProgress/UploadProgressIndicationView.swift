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

import DesignSystem
import InfomaniakCoreSwiftUI
import STResources
import SwiftUI
import SwissTransferCoreUI

enum ProgressStatus {
    case initializing
    case uploading(fractionCompleted: Double, totalBytes: Int64)
}

struct UploadProgressIndicationView: View {
    @StateObject private var reachabilityObserver = ReachabilityObserver()

    let status: ProgressStatus

    private var percentCompleted: Double {
        switch status {
        case .initializing:
            return 0
        case .uploading(let fractionCompleted, let totalBytes):
            guard totalBytes > 0 else { return 0 }
            return fractionCompleted
        }
    }

    private var isOnline: Bool {
        let networkStatus = reachabilityObserver.networkStatus
        return networkStatus == .wifi || networkStatus == .cellular
    }

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            Text(STResourcesStrings.Localizable.uploadProgressIndication)
                .font(.ST.title2)
                .foregroundStyle(Color.ST.textPrimary)

            Group {
                if isOnline {
                    Group {
                        switch status {
                        case .initializing:
                            Text(STResourcesStrings.Localizable.transferInitializing)
                        case .uploading(let fractionCompleted, let totalBytes):
                            HStack(spacing: IKPadding.micro) {
                                Text(percentCompleted, format: .defaultPercent)
                                Text("-")
                                HStack(spacing: 2) {
                                    Text(Int64(fractionCompleted * Double(totalBytes)), format: .progressByteCount)
                                    Text("/")
                                    Text(totalBytes, format: .progressByteCount)
                                }
                            }
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
    UploadProgressIndicationView(status: .uploading(fractionCompleted: 0.5, totalBytes: 42))
}

#Preview {
    UploadProgressIndicationView(status: .initializing)
}
