//
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

    var title: String {
        return "\(self)"
    }
}

struct NotificationsSettings: View {
    @EnvironmentObject private var mainViewState: MainViewState

    @StateObject var appSettings: FlowObserver<AppSettings>

    @State var enabled = true

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    var body: some View {
        List {
            Section(header: Text(STResourcesStrings.Localizable.settingsNotificationsTitle)) {
                ForEach(NotificationsSettingsModel.allCases, id: \.self) { item in
                    NotificationSettingCell(label: item.title, enabled: $enabled)
                }
            }
        }
        .stNavigationBarStyle()
    }
}

#Preview {
    NotificationsSettings()
}
