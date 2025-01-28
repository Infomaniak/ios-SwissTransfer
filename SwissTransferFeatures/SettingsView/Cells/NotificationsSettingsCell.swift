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
import STResources
import SwiftUI
import SwissTransferCore

/// A view that tracks the notifications settings
struct NotificationsSettingsCell<Content: View>: View {
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

    @State private var subtitle: String = NotificationSettings().enabledNotificationLabel

    @ViewBuilder var destination: () -> Content

    private let leftIconAsset = STResourcesAsset.Images.bell

    private let title: String = STResourcesStrings.Localizable.settingsOptionNotifications

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: IKPadding.mini) {
                Image(asset: leftIconAsset)
                    .iconSize(.large)
                    .foregroundColor(Color.ST.primary)

                VStack(alignment: .leading) {
                    Text(title)
                        .lineLimit(1)
                        .foregroundStyle(Color.ST.textPrimary)
                        .font(.ST.body)
                    Text(subtitle)
                        .lineLimit(1)
                        .foregroundStyle(Color.ST.textSecondary)
                        .font(.ST.callout)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: [
                    newTransfers,
                    downloadInProgress,
                    finishedTransfers,
                    downloadTransfers,
                    failedTransfers,
                    expiredTransfers
                ]) { newValue in
                    let allEnabled = newValue.allSatisfy { $0 }
                    if allEnabled {
                        self.subtitle = STResourcesStrings.Localizable.settingsAllNotifications
                    } else {
                        self.subtitle = STResourcesStrings.Localizable.settingsCustomizedNotifications
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationsSettingsCell {
        Text("NotificationsSettingsCell action")
    }
}
