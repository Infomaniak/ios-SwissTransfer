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
import UIKit

public final class UIFocusableRecipientChipView: UIView, UIKeyInput {
    private static let buttonImageSize: CGFloat = 12
    private static let buttonInset = IKPadding.small

    public var shouldDisplayButton = false {
        didSet {
            toggleButton()
        }
    }
    public var didPressTabKey: (() -> Void)?
    public var removeRecipient: (() -> Void)?

    private let text: String
    private var buttonConstraints = [NSLayoutConstraint]()

    public let hasText = false

    override public var canBecomeFirstResponder: Bool {
        return isUserInteractionEnabled
    }

    override public var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let buttonSize = button.intrinsicContentSize

        var labelWidth = labelSize.width + IKPadding.intermediate
        var buttonWidth = CGFloat.zero
        if shouldDisplayButton {
            buttonWidth = Self.buttonImageSize + Self.buttonInset * 2
        } else {
            labelWidth += IKPadding.intermediate
        }

        let width = labelWidth + buttonWidth
        let height = max(labelSize.height + 6 * 2, buttonSize.height)
        return CGSize(width: width, height: height)
    }

    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private var button: UIButton = {
        let button = UIButton(configuration: .plain())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.image = UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: buttonImageSize))
        return button
    }()

    public init(text: String) {
        self.text = text
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func becomeFirstResponder() -> Bool {
        updateColors(isFirstResponder: true)
        return super.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        updateColors(isFirstResponder: false)
        return super.resignFirstResponder()
    }

    public func insertText(_ text: String) {
        if text == "\t" {
            didPressTabKey?()
        }
    }

    public func deleteBackward() {
        removeRecipient?()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8

        label.text = text
        addSubview(label)

        let action = UIAction { [weak self] _ in
            self?.removeRecipient?()
        }
        button.addAction(action, for: .touchUpInside)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: IKPadding.intermediate),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: IKPadding.intermediate),
        ])

        buttonConstraints = [
            label.trailingAnchor.constraint(equalTo: button.leadingAnchor),

            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: Self.buttonImageSize + 2 * Self.buttonInset)
        ]

        updateColors()
        toggleButton()
    }

    private func updateColors(isFirstResponder: Bool = false) {
        backgroundColor = isFirstResponder ? .ST.onRecipientLabelBackground : .ST.recipientLabelBackground

        let foregroundColor = isFirstResponder ? UIColor.ST.onRecipientLabelBackground : UIColor.ST.recipientLabelBackground
        label.textColor = foregroundColor
        button.tintColor = foregroundColor
    }

    private func toggleButton() {
        if shouldDisplayButton {
            addSubview(button)
            NSLayoutConstraint.activate(buttonConstraints)
        } else {
            willRemoveSubview(button)
            button.removeFromSuperview()
            NSLayoutConstraint.deactivate(buttonConstraints)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    return UIFocusableRecipientChipView(text: "john.smith@ik.me")
}

@available(iOS 17.0, *)
#Preview {
    let chip = UIFocusableRecipientChipView(text: "john.smith@ik.me")
    chip.shouldDisplayButton = true
    return chip
}
