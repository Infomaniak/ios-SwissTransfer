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

public struct FocusableRecipientView: UIViewRepresentable {
    private let recipient: String
    private let shouldDisplayButton: Bool
    public let didPressTabKey: (() -> Void)?
    public let removeRecipient: (() -> Void)?

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

    public func makeUIView(context: Context) -> UIFocusableRecipientView {
        let recipientView = UIFocusableRecipientView(text: recipient)
        recipientView.shouldDisplayButton = shouldDisplayButton
        recipientView.didPressTabKey = didPressTabKey
        recipientView.removeRecipient = removeRecipient
        return recipientView
    }

    public func updateUIView(_ uiView: UIFocusableRecipientView, context: Context) {

    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIFocusableRecipientView, context: Context) -> CGSize? {
        return uiView.intrinsicContentSize
    }
}

#Preview {
    VStack {
        FocusableRecipientView(recipient: "john.smith@ik.me", shouldDisplayButton: false)
        FocusableRecipientView(recipient: "john.smith@ik.me", shouldDisplayButton: true)
    }
}
