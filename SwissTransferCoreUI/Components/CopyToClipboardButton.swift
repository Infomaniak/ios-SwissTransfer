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
import STCore
import STResources
import SwiftUI

public struct CopyToClipboardButton<Item, Style: LabelStyle>: View {
    @State private var isCopying = false

    private let animation = Animation.default.speed(1.5)

    let text: String
    let item: Item
    let labelStyle: Style
    let matomoCategory: MatomoCategory
    let matomoName: MatomoName

    public init(text: String, item: Item, labelStyle: Style, matomoCategory: MatomoCategory, matomoName: MatomoName) {
        self.text = text
        self.item = item
        self.labelStyle = labelStyle
        self.matomoCategory = matomoCategory
        self.matomoName = matomoName
    }

    public var body: some View {
        Button(action: copyToClipboard) {
            Label {
                Text(text)
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
            .labelStyle(labelStyle)
        }
    }

    private func copyToClipboard() {
        @InjectService var matomo: MatomoUtils
        matomo.track(eventWithCategory: matomoCategory, name: matomoName)

        if let url = item as? URL {
            UIPasteboard.general.url = url
        } else if let text = item as? String {
            UIPasteboard.general.string = text
        } else {
            return
        }

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
    CopyToClipboardButton(
        text: STResourcesStrings.Localizable.buttonCopyLink,
        item: URL(string: "https://www.infomaniak.com")!,
        labelStyle: .verticalButton,
        matomoCategory: .newTransfer,
        matomoName: .copyLink
    )
}
