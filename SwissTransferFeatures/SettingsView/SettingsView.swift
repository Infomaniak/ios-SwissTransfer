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
import SwiftUI
import SwissTransferCore

public struct SettingsView: View {
    @LazyInjectService var settingsManager: AppSettingsManager

    @StateObject var appSettings: FlowObserver<AppSettings>

    public init() {
        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    public var body: some View {
        VStack {
            Text("SettingsView")
            if let appSettings = appSettings.value {
                Text(appSettings.theme.name)
            }
            Button("Toggle") {
                Task {
                    if let appSettings = appSettings.value {
                        try? await settingsManager.setTheme(theme: appSettings.theme == .dark ? .light : .dark)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
