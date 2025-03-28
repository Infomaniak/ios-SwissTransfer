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

import SwiftUI

public struct STFocusableChipView: UIViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled

    private let recipient: String
    private let shouldDisplayButton: Bool
    private let didPressTabKey: (() -> Void)?
    private let removeRecipient: (() -> Void)?

    public init(
        recipient: String,
        shouldDisplayButton: Bool,
        didPressTabKey: (() -> Void)? = nil,
        removeRecipient: (() -> Void)? = nil
    ) {
        self.recipient = recipient
        self.shouldDisplayButton = shouldDisplayButton
        self.didPressTabKey = didPressTabKey
        self.removeRecipient = removeRecipient
    }

    public func makeUIView(context: Context) -> UISTFocusableChipView {
        let recipientView = UISTFocusableChipView(text: recipient)
        recipientView.shouldDisplayButton = shouldDisplayButton
        recipientView.didPressTabKey = didPressTabKey
        recipientView.removeRecipient = removeRecipient
        recipientView.isUserInteractionEnabled = isEnabled
        return recipientView
    }

    public func updateUIView(_ uiView: UISTFocusableChipView, context: Context) {
        uiView.shouldDisplayButton = shouldDisplayButton
        uiView.text = recipient
        uiView.isUserInteractionEnabled = isEnabled
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISTFocusableChipView, context: Context) -> CGSize? {
        let intrinsicContentSize = uiView.intrinsicContentSize
        let minWidth = min(proposal.width ?? .infinity, intrinsicContentSize.width)
        return CGSize(width: minWidth, height: intrinsicContentSize.height)
    }
}

#Preview {
    VStack {
        STFocusableChipView(recipient: "john.smith@ik.me", shouldDisplayButton: false)
        STFocusableChipView(recipient: "john.smith@ik.me", shouldDisplayButton: true)
    }
}
