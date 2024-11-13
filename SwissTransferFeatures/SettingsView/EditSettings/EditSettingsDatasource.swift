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
protocol EditCellModelable {
    var label: String { get }
    var action: () -> Void { get }
    var leftIconAsset: STResourcesImages? { get }
}

struct EditCellModel: EditCellModelable, Hashable, Equatable {
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
    var cellsModel: [EditCellModel] { get }
}

struct EditThemeDatasource: EditSettingsModel {
    let source = SettingDetailUi.theme
    let title = STResourcesStrings.Localizable.settingsThemeTitle
    let selectedTheme: Theme?
    var cellsModel = [EditCellModel]()

    init(appSettings: AppSettings?) {
        selectedTheme = appSettings?.theme
        cellsModel = Theme.allCases.map { setting in
            EditCellModel(
                label: setting.localized,
                action: action(forSetting: setting),
                rightIconAsset: rightIconAsset(forSetting: setting)
            )
        }
    }

    private func rightIconAsset(forSetting setting: Theme) -> STResourcesImages? {
        guard setting == selectedTheme else { return nil }
        return STResourcesAsset.Images.check
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
    let selectedValidity: ValidityPeriod?
    var cellsModel = [EditCellModel]()

    init(appSettings: AppSettings?) {
        selectedValidity = appSettings?.validityPeriod
        cellsModel = ValidityPeriod.allCases.map { setting in
            EditCellModel(label: setting.localized,
                          action: action(forSetting: setting),
                          rightIconAsset: rightIconAsset(forSetting: setting))
        }
    }

    private func rightIconAsset(forSetting setting: ValidityPeriod) -> STResourcesImages? {
        guard setting == selectedValidity else { return nil }
        return STResourcesAsset.Images.check
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
    let selectedDownloadLimit: DownloadLimit?
    var cellsModel = [EditCellModel]()

    init(appSettings: AppSettings?) {
        selectedDownloadLimit = appSettings?.downloadLimit
        cellsModel = DownloadLimit.allCases.map { setting in
            EditCellModel(label: setting.localized,
                          action: action(forSetting: setting),
                          rightIconAsset: rightIconAsset(forSetting: setting))
        }
    }

    private func rightIconAsset(forSetting setting: DownloadLimit) -> STResourcesImages? {
        guard setting == selectedDownloadLimit else { return nil }
        return STResourcesAsset.Images.check
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
    let selectedEmailLanguage: EmailLanguage?
    var cellsModel = [EditCellModel]()

    init(appSettings: AppSettings?) {
        selectedEmailLanguage = appSettings?.emailLanguage
        cellsModel = EmailLanguage.allCases.map { setting in
            EditCellModel(label: setting.localized,
                          action: action(forSetting: setting),
                          leftIconAsset: setting.leftIcon,
                          rightIconAsset: rightIconAsset(forSetting: setting))
        }
    }

    private func rightIconAsset(forSetting setting: EmailLanguage) -> STResourcesImages? {
        guard setting == selectedEmailLanguage else { return nil }
        return STResourcesAsset.Images.check
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
