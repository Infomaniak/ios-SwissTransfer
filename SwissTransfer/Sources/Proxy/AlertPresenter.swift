/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

import SwissTransferCore
import UIKit

@MainActor
public final class AlertPresenter: AlertPresentable {
    private var alertWindow: UIWindow?

    public nonisolated init() {}

    public func show(title: String, message: String?, actions: [UIAlertAction]) {
        let alert = AlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }

        alert.onDismiss = { [weak self] in
            self?.alertWindow?.isHidden = true
            self?.alertWindow = nil
        }

        presentInDedicatedWindow(alert)
    }

    private func presentInDedicatedWindow(_ alert: UIAlertController) {
        if let alertWindow {
            alertWindow.isHidden = true
            self.alertWindow = nil
        }

        let window = AlertWindow()
        window.rootViewController = AlertHostViewController(alert: alert)
        window.windowLevel = .alert
        window.makeKeyAndVisible()
        alertWindow = window
    }
}

private final class AlertWindow: UIWindow {
    init() {
        if let activeForegroundScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            super.init(windowScene: activeForegroundScene)
        } else if let inactiveForegroundScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundInactive }) as? UIWindowScene {
            super.init(windowScene: inactiveForegroundScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class AlertHostViewController: UIViewController {
    private let alert: UIAlertController

    init(alert: UIAlertController) {
        self.alert = alert
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(alert, animated: true)
    }
}

private final class AlertController: UIAlertController {
    var onDismiss: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
}
