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

import InfomaniakDI
import STRootTransferView
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI
import UIKit

class ShareViewController: UIViewController {
    // periphery:ignore - Making sure the Sentry is initialized at a very early stage of the extension launch.
    private let sentryService = SentryService()
    // periphery:ignore - Making sure the DI is registered at a very early stage of the extension launch.
    private let dependencyInjectionHook = TargetAssembly()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Modify sheet size on iPadOS, property is ignored on iOS
        preferredContentSize = CGSize(width: 540, height: 620)

        guard let extensionItems: [NSExtensionItem] = extensionContext?.inputItems.compactMap({ $0 as? NSExtensionItem }),
              !extensionItems.isEmpty else {
            dismiss(animated: true)
            return
        }

        let itemProviders: [NSItemProvider] = extensionItems.filteredItemProviders
        guard !itemProviders.isEmpty else {
            dismiss(animated: true)
            return
        }

        let importedItems = itemProviders.map { ImportedItem(item: $0) }

        Task {
            @InjectService var accountManager: AccountManager
            guard let userSession = await accountManager.getCurrentUserSession() else {
                dismiss(animated: true)
                return
            }

            let mainViewState = MainViewState(
                swissTransferManager: userSession.swissTransferManager,
                uploadBackendRouter: UploadBackendRouter(
                    currentUser: userSession.userProfile,
                    swissTransferManager: userSession.swissTransferManager
                )
            )

            let rootTransferView = RootTransferView(initialItems: importedItems, currentUser: userSession.userProfile)
                .tint(.ST.primary)
                .ikButtonTheme(.swissTransfer)
                .detectCompactWindow()
                .environment(\.shareExtensionContext, ShareExtensionContext { self.dismiss(animated: true) })
                .environment(\.currentUser, userSession.userProfile)
                .environmentObject(mainViewState)
                .defaultAppStorage(.shared)

            let hostingController = UIHostingController(rootView: rootTransferView)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.didMove(toParent: self)

            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
