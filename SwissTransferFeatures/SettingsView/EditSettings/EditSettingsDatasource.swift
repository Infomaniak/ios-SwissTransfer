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

/// Something used to populate a `EditSettingsView`
protocol EditCellModel {
    var label: String { get }
    var action: () -> Void { get }
    var leftIconAsset: STResourcesImages? { get }
}

struct EditCellDatom: EditCellModel, Hashable, Equatable {
    let label: String
    let action: () -> Void
    let leftIconAsset: STResourcesImages?
    let rightIconAsset: STResourcesImages?

    init(label: String,
         action: @escaping () -> Void,
         leftIconAsset: STResourcesImages? = nil,
         rightIconAsset: STResourcesImages? = nil) {
        self.label = label
        self.action = action
        self.leftIconAsset = leftIconAsset
        self.rightIconAsset = rightIconAsset
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.label == rhs.label
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}

protocol EditSettingsModel {
    var source: SettingDetailUi { get }
    var title: String { get }
    var cellsModel: [EditCellDatom] { get }
}

struct EditThemeDatasource: EditSettingsModel {
    let source = SettingDetailUi.theme
    let title = STResourcesStrings.Localizable.settingsThemeTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = [
            EditCellDatom(label: Theme.system.localized, action: action(forSetting: .system)),
            EditCellDatom(label: Theme.light.localized, action: action(forSetting: .light)),
            EditCellDatom(label: Theme.dark.localized, action: action(forSetting: .dark))
        ]
    }

    private func action(forSetting setting: Theme) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setTheme(theme: setting)
            }
        }
        return lambda
    }
}

struct EditValidityPeriodDatasource: EditSettingsModel {
    let source = SettingDetailUi.validityPeriod
    let title = STResourcesStrings.Localizable.settingsValidityPeriodTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = ValidityPeriod.allCases.map { setting in
            EditCellDatom(label: setting.localized, action: action(forSetting: setting))
        }
    }

    private func action(forSetting setting: ValidityPeriod) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setValidityPeriod(validityPeriod: setting)
            }
        }
        return lambda
    }
}

struct EditDownloadLimitDatasource: EditSettingsModel {
    let source = SettingDetailUi.downloadLimit
    let title = STResourcesStrings.Localizable.settingsDownloadsLimitTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = DownloadLimit.allCases.map { setting in
            EditCellDatom(label: setting.localized, action: action(forSetting: setting))
        }
    }

    private func action(forSetting setting: DownloadLimit) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setDownloadLimit(downloadLimit: setting)
            }
        }
        return lambda
    }
}

struct EditEmailLanguageDatasource: EditSettingsModel {
    let source = SettingDetailUi.emailLanguage
    let title = STResourcesStrings.Localizable.settingsEmailLanguageTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = EmailLanguage.allCases.map { setting in
            EditCellDatom(label: setting.localized, action: action(forSetting: setting), leftIconAsset: setting.leftIcon)
        }
    }

    private func action(forSetting setting: EmailLanguage) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setEmailLanguage(emailLanguage: setting)
            }
        }
        return lambda
    }
}
