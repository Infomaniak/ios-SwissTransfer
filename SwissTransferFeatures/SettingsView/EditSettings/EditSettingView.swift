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

struct EditSettingView: View {
    @EnvironmentObject private var mainViewState: MainViewState
    @Environment(\.dismiss) private var dismiss

    @LazyInjectService private var settingsManager: AppSettingsManager

    @StateObject private var appSettings: FlowObserver<AppSettings>

    private let datasource: EditSettingsModel

    public init(datasource: EditSettingsModel) {
        self.datasource = datasource

        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            Section(header: Text(datasource.title)) {
                ForEach(datasource.cellsModel, id: \.self) { item in
                    EditSettingsView(leftIconAsset: item.leftIconAsset, rightIconAsset: item.rightIconAsset, label: item.label) {
                        dismiss()
                        item.action()
                    }
                }
            }
        }
        .stNavigationBarStyle()
    }
}

#Preview {
    let model = EditThemeDatasource(appSettings: nil)
    EditSettingView(datasource: model)
}
