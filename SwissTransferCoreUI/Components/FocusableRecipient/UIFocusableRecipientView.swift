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

public final class UIFocusableRecipientView: UIView, UIKeyInput {
    private static let buttonImageSize: CGFloat = 8
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

        var labelWidth = labelSize.width + IKPadding.small
        var buttonWidth = CGFloat.zero
        if shouldDisplayButton {
            buttonWidth = Self.buttonImageSize + Self.buttonInset * 2
        } else {
            labelWidth += IKPadding.small
        }

        let width = labelWidth + buttonWidth
        let height = max(labelSize.height + IKPadding.extraSmall * 2, buttonSize.height)
        return CGSize(width: width, height: height)
    }

    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
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
        layer.cornerRadius = intrinsicContentSize.height / 2

        label.text = text
        addSubview(label)

        let action = UIAction { [weak self] _ in
            self?.removeRecipient?()
        }
        button.addAction(action, for: .touchUpInside)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: IKPadding.extraSmall),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: IKPadding.small),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -IKPadding.small),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -IKPadding.extraSmall),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        buttonConstraints = [
            button.leadingAnchor.constraint(equalTo: label.trailingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: Self.buttonImageSize + 2 * Self.buttonImageSize)
        ]

        updateColors()
    }

    private func updateColors(isFirstResponder: Bool = false) {
        backgroundColor = isFirstResponder ? .ST.onRecipientLabelBackground : .ST.recipientLabelBackground

        let foregroundColor = isFirstResponder ? UIColor.ST.recipientLabelBackground : UIColor.ST.onRecipientLabelBackground
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
    return UIFocusableRecipientView(text: "john.smith@ik.me")
}
