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

import InfomaniakDI
import STCore
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

enum NotificationsSettingsModel: Hashable, CaseIterable {
    case allNotifications
    case newTransfers
    case downloadsInProgress
    case finishedTransfers
    case downloadTransfers
    case failedTransfers
    case expiredTransfers

    var localized: String {
        switch self {
        case .allNotifications:
            STResourcesStrings.Localizable.settingsAllNotifications
        case .newTransfers:
            STResourcesStrings.Localizable.settingsNotificationsTransferInProgress
        case .downloadsInProgress:
            STResourcesStrings.Localizable.settingsNotificationsDownloadInProgress
        case .finishedTransfers:
            STResourcesStrings.Localizable.settingsNotificationsTransferFinished
        case .downloadTransfers:
            STResourcesStrings.Localizable.settingsNotificationsDownloadTransfer
        case .failedTransfers:
            STResourcesStrings.Localizable.settingsNotificationsTransferNotDownloaded
        case .expiredTransfers:
            STResourcesStrings.Localizable.settingsNotificationsLinkExpired
        }
    }
}

struct NotificationsSettingsView: View {
    @AppStorage(UserDefaults.shared.key(.notificationsNewTransfers))
    private var newTransfers = DefaultPreferences.notificationsNewTransfers

    @AppStorage(UserDefaults.shared.key(.notificationsDownloadInProgress))
    private var downloadInProgress = DefaultPreferences.notificationsDownloadInProgress

    @AppStorage(UserDefaults.shared.key(.notificationsFinishedTransfers))
    private var finishedTransfers = DefaultPreferences.notificationsFinishedTransfers

    @AppStorage(UserDefaults.shared.key(.notificationsDownloadTransfers))
    private var downloadTransfers = DefaultPreferences.notificationsDownloadTransfers

    @AppStorage(UserDefaults.shared.key(.notificationsFailedTransfers))
    private var failedTransfers = DefaultPreferences.notificationsFailedTransfers

    @AppStorage(UserDefaults.shared.key(.notificationsExpiredTransfers))
    private var expiredTransfers = DefaultPreferences.notificationsExpiredTransfers

    @State private var allNotificationsEnabled = NotificationSettings().allEnabled

    @State private var mutationFromCode = false

    init() {
        allNotificationsEnabled = computeAllNotificationsEnabled()
    }

    var body: some View {
        List {
            Section(header: Text(STResourcesStrings.Localizable.settingsNotificationsTitle)) {
                ForEach(NotificationsSettingsModel.allCases, id: \.self) { setting in
                    NotificationSettingCell(enabled: toggleBinding(for: setting), label: setting.localized)
                }
            }
        }
        .onAppear {
            allNotificationsEnabled = NotificationSettings().allEnabled
        }
        .onChange(of: [newTransfers,
                       downloadInProgress,
                       finishedTransfers,
                       downloadTransfers,
                       failedTransfers,
                       expiredTransfers]) { newValue in
            let allNotifications = newValue.allSatisfy { $0 }
            guard allNotificationsEnabled != allNotifications else {
                return
            }

            mutationFromCode = true
            allNotificationsEnabled = allNotifications
        }
        .onChange(of: allNotificationsEnabled) { newValue in
            guard !mutationFromCode else {
                mutationFromCode = false
                return
            }

            newTransfers = newValue
            downloadInProgress = newValue
            finishedTransfers = newValue
            downloadTransfers = newValue
            failedTransfers = newValue
            expiredTransfers = newValue
        }
        .stNavigationBarStyle()
        .stNavigationTitle(STResourcesStrings.Localizable.settingsOptionNotifications)
    }

    private func computeAllNotificationsEnabled() -> Bool {
        for setting in NotificationsSettingsModel.allCases {
            guard setting != .allNotifications else {
                continue
            }

            let binding = toggleBinding(for: setting)
            guard binding.wrappedValue else {
                return false
            }
        }

        return true
    }

    private func toggleBinding(for setting: NotificationsSettingsModel) -> Binding<Bool> {
        switch setting {
        case .allNotifications:
            return $allNotificationsEnabled
        case .newTransfers:
            return $newTransfers
        case .downloadsInProgress:
            return $downloadInProgress
        case .finishedTransfers:
            return $finishedTransfers
        case .downloadTransfers:
            return $downloadTransfers
        case .failedTransfers:
            return $failedTransfers
        case .expiredTransfers:
            return $expiredTransfers
        }
    }
}
