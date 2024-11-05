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
    let completedBytes: Int64
    let totalBytes: Int64

    private var percentCompleted: Double {
        return Double(completedBytes) / Double(totalBytes)
    }

    var body: some View {
        VStack(spacing: IKPadding.small) {
            Text(STResourcesStrings.Localizable.uploadProgressIndication)
                .font(.ST.headline)
                .foregroundStyle(Color.ST.textPrimary)

            HStack(spacing: IKPadding.extraSmall) {
                Text(percentCompleted, format: .defaultPercent)
                Text("-")
                HStack(spacing: 2) {
                    Text(completedBytes, format: .progressByteCount)
                    Text("/")
                    Text(totalBytes, format: .progressByteCount)
                }
            }
            .font(.ST.caption)
            .foregroundStyle(Color.ST.textSecondary)
        }
    }
}

#Preview {
    UploadProgressIndicationView(completedBytes: 12, totalBytes: 42)
}
