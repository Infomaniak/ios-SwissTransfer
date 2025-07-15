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

import Foundation
import InfomaniakCoreCommonUI
import InfomaniakDI
import STCore
import SwiftUI

public extension MatomoUtils {
    static let siteID = "24"
    static let siteURL = URL(string: "https://analytics.infomaniak.com/matomo.php")!

    func track(eventWithCategory category: MatomoCategory, action: UserAction = .click, name: MatomoName, value: Float? = nil) {
        track(eventWithCategory: category.value, action: action, name: name.value, value: value)
    }
}

// MARK: - Views and Categories

public extension MatomoUtils.EventCategory {
    static let transferType = MatomoUtils.EventCategory(displayName: "transferType")
    static let newTransferData = MatomoUtils.EventCategory(displayName: "newTransferData")

    // MARK: - New Transfer

    static let newTransfer = MatomoUtils.EventCategory(displayName: "newTransfer")

    // MARK: - Transfer

    static let sentTransfer = MatomoUtils.EventCategory(displayName: "sentTransfer")
    static let receivedTransfer = MatomoUtils.EventCategory(displayName: "receivedTransfer")

    // MARK: - Transfer errors

    static let newTransferError = MatomoUtils.EventCategory(displayName: "newTransferError")

    // MARK: - Import File Type

    static let importFileFromSent = MatomoUtils.EventCategory(displayName: "importFileFromSent")
    static let importFileFromReceived = MatomoUtils.EventCategory(displayName: "importFileFromReceived")
    static let importFromNewTransfer = MatomoUtils.EventCategory(displayName: "importFromNewTransfer")
    static let importFromFileList = MatomoUtils.EventCategory(displayName: "importFromFileList")
    static let importFromSidebar = MatomoUtils.EventCategory(displayName: "importFromSidebar")

    // MARK: - General and Local Settings

    static let settingsGlobalValidityPeriod = MatomoUtils.EventCategory(displayName: "settingsGlobalValidityPeriod")
    static let settingsGlobalDownloadLimit = MatomoUtils.EventCategory(displayName: "settingsGlobalDownloadLimit")
    static let settingsGlobalEmailLanguage = MatomoUtils.EventCategory(displayName: "settingsGlobalEmailLanguage")

    static let settingsLocalValidityPeriod = MatomoUtils.EventCategory(displayName: "settingsLocalValidityPeriod")
    static let settingsLocalDownloadLimit = MatomoUtils.EventCategory(displayName: "settingsLocalDownloadLimit")
    static let settingsLocalEmailLanguage = MatomoUtils.EventCategory(displayName: "settingsLocalEmailLanguage")

    // MARK: - Local settings

    static let settingsLocalPassword = MatomoUtils.EventCategory(displayName: "settingsLocalPassword")

    // MARK: - Global Settings

    static let settingsGlobalTheme = MatomoUtils.EventCategory(displayName: "settingsTheme")
    static let settingsGlobalNotifications = MatomoUtils.EventCategory(displayName: "settingsNotifications")
}

// MARK: - Track views

struct MatomoView: ViewModifier {
    @LazyInjectService var matomo: MatomoUtils

    let path: [String]

    // TODO: Remove these inits when you're done
    init(path: [String]) {
        self.path = path
    }

    init(view: String) {
        path = [view]
    }

    // TODO: -- End

    init(view: MatomoScreen) {
        path = [view.value]
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                matomo.track(view: path)
            }
    }
}

public extension View {
    func matomoView(view: MatomoScreen) -> some View {
        modifier(MatomoView(view: view))
    }

    // TODO: Remove this func when you're done
    func matomoView(view: String) -> some View {
        modifier(MatomoView(view: view))
    }
}
