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

    init(label: String, action: @escaping () -> Void, leftIconAsset: STResourcesImages? = nil) {
        self.label = label
        self.action = action
        self.leftIconAsset = leftIconAsset
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
    enum Setting {
        case system
        case light
        case dark

        var theme: STCore.Theme {
            switch self {
            case .system:
                return .system
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }

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

    private func action(forSetting setting: Setting) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setTheme(theme: setting.theme)
            }
        }
        return lambda
    }
}

struct EditValidityPeriodDatasource: EditSettingsModel {
    // TODO: i18n
    enum Setting: String, CaseIterable {
        case thirtyDays = "30 days"
        case fifteenDays = "15 days"
        case sevenDays = "7 days"
        case oneDay = "1 day"

        var validityPeriod: ValidityPeriod {
            switch self {
            case .thirtyDays:
                ValidityPeriod.thirty
            case .fifteenDays:
                ValidityPeriod.fifteen
            case .sevenDays:
                ValidityPeriod.seven
            case .oneDay:
                ValidityPeriod.one
            }
        }
    }

    let source = SettingDetailUi.validityPeriod
    let title = STResourcesStrings.Localizable.settingsValidityPeriodTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = Setting.allCases.map { setting in
            EditCellDatom(label: setting.rawValue, action: action(forSetting: setting))
        }
    }

    private func action(forSetting setting: Setting) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setValidityPeriod(validityPeriod: setting.validityPeriod)
            }
        }
        return lambda
    }
}

struct EditDownloadLimitDatasource: EditSettingsModel {
    // TODO: i18n
    enum Setting: String, CaseIterable {
        case twoHundredFifty = "250"
        case oneHundred = "100"
        case twenty = "20"
        case one = "1"

        var downloadLimit: STCore.DownloadLimit {
            switch self {
            case .twoHundredFifty:
                .twoHundredFifty
            case .oneHundred:
                .oneHundred
            case .twenty:
                .twenty
            case .one:
                .one
            }
        }
    }

    let source = SettingDetailUi.downloadLimit
    let title = STResourcesStrings.Localizable.settingsDownloadsLimitTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = Setting.allCases.map { setting in
            EditCellDatom(label: setting.rawValue, action: action(forSetting: setting))
        }
    }

    private func action(forSetting setting: Setting) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setDownloadLimit(downloadLimit: setting.downloadLimit)
            }
        }
        return lambda
    }
}

struct EditEmailLanguageDatasource: EditSettingsModel {
    enum Setting: CaseIterable {
        case english
        case french
        case german
        case italian
        case spanish

        var emailLanguage: EmailLanguage {
            switch self {
            case .french:
                .french
            case .german:
                .german
            case .italian:
                .italian
            case .spanish:
                .spanish
            case .english:
                .english
            }
        }

        var localized: String {
            switch self {
            case .english:
                return STResourcesStrings.Localizable.settingsEmailLanguageValueEnglish
            case .french:
                return STResourcesStrings.Localizable.settingsEmailLanguageValueFrench
            case .german:
                return STResourcesStrings.Localizable.settingsEmailLanguageValueGerman
            case .italian:
                return STResourcesStrings.Localizable.settingsEmailLanguageValueItalian
            case .spanish:
                return STResourcesStrings.Localizable.settingsEmailLanguageValueSpanish
            }
        }

        var leftIcon: STResourcesImages {
            switch self {
            case .english:
                return STResourcesAsset.Images.flagUk
            case .french:
                return STResourcesAsset.Images.flagFr
            case .german:
                return STResourcesAsset.Images.flagDe
            case .italian:
                return STResourcesAsset.Images.flagIt
            case .spanish:
                return STResourcesAsset.Images.flagEs
            }
        }
    }

    let source = SettingDetailUi.emailLanguage
    let title = STResourcesStrings.Localizable.settingsEmailLanguageTitle
    var cellsModel = [EditCellDatom]()

    init() {
        cellsModel = Setting.allCases.map { setting in
            EditCellDatom(label: setting.localized, action: action(forSetting: setting), leftIconAsset: setting.leftIcon)
        }
    }

    private func action(forSetting setting: Setting) -> () -> Void {
        let lambda: () -> Void = {
            Task {
                @InjectService var settingsManager: AppSettingsManager
                _ = try? await settingsManager.setEmailLanguage(emailLanguage: setting.emailLanguage)
            }
        }
        return lambda
    }
}
