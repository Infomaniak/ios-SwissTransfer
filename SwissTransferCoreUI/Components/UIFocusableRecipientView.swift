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

final class UIFocusableRecipientView: UIView, UIKeyInput {
    private static let buttonImageSize: CGFloat = 8
    private static let buttonInset = IKPadding.small

    var didPressTabKey: (() -> Void)?
    var didPressDeleteKey: (() -> Void)?

    private let text: String
    private var buttonConstraints = [NSLayoutConstraint]()

    var hasText: Bool {
        return false
    }

    override var canBecomeFirstResponder: Bool {
        return isUserInteractionEnabled
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let buttonWidth = isFirstResponder ? Self.buttonImageSize + Self.buttonInset * 2 : .zero

        let width = labelSize.width + buttonWidth
        return CGSize(width: width, height: labelSize.height)
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

    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func becomeFirstResponder() -> Bool {
        handleFirstResponder()
        return super.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        handleFirstResponder()
        return super.resignFirstResponder()
    }

    func insertText(_ text: String) {
        if text == "\t" {
            didPressTabKey?()
        }
    }

    func deleteBackward() {
        didPressDeleteKey?()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        label.text = text
        addSubview(label)

        layer.cornerRadius = intrinsicContentSize.height * 0.66

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

    private func handleFirstResponder() {
        updateColors()
        toggleButton()
    }

    private func updateColors() {
        backgroundColor = isFirstResponder ? .ST.onRecipientLabelBackground : .ST.recipientLabelBackground

        let foregroundColor = isFirstResponder ? UIColor.ST.recipientLabelBackground : UIColor.ST.onRecipientLabelBackground
        label.textColor = foregroundColor
        button.tintColor = foregroundColor
    }

    private func toggleButton() {
        if isFirstResponder {
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
    let view = UIFocusableRecipientView(text: "john.smith@ik.me")
    return view
}
