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

import Foundation
import STCore
import STResources
import SwissTransferCore

extension SettingDetailUi {
    // The data needed to display an `EditSetting` view, inferred from `SettingDetailUi`
    func model(with appSettings: AppSettings?) -> EditSettingsModel? {
        switch self {
        case .theme:
            return EditThemeSettingsModel(appSettings: appSettings)
        case .validityPeriod:
            return EditValidityPeriodModel(appSettings: appSettings)
        case .downloadLimit:
            return EditDownloadLimitModel(appSettings: appSettings)
        case .emailLanguage:
            return EditEmailLanguageModel(appSettings: appSettings)
        default:
            return nil
        }
    }
}

/// Links used in the settings view
enum SettingLinks {
    static let discoverInfomaniak = URL(string: "https://www.infomaniak.com/en/about")!
    static let shareYourIdeas =
        URL(string: "https://feedback.userreport.com/f12466ad-db5b-4f5c-b24c-a54b0a5117ca/#ideas/popular")!
}
