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

struct CopyToClipboardButton: View {
    @State private var isCopying = false

    private let animation = Animation.default.speed(1.5)

    let url: URL

    var body: some View {
        Button(action: copyLinkToClipboard) {
            Label {
                Text(STResourcesStrings.Localizable.buttonCopyLink)
            } icon: {
                Group {
                    if isCopying {
                        STResourcesAsset.Images.check.swiftUIImage
                    } else {
                        STResourcesAsset.Images.documentOnDocument.swiftUIImage
                    }
                }
                .transition(.scale)
            }
            .labelStyle(.verticalButton)
        }
    }

    private func copyLinkToClipboard() {
        UIPasteboard.general.url = url

        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.success)

        withAnimation(animation) {
            isCopying = true
        }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(animation) {
                isCopying = false
            }
        }
    }
}

#Preview {
    CopyToClipboardButton(url: URL(string: "https://www.infomaniak.com")!)
}
