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

extension DownloadLimit: SettingSelectable {
    public var title: String {
        return "\(value)"
    }

    public var leftImage: Image? {
        nil
    }

    public var matomoName: MatomoName {
        switch self {
        case .one:
            return .oneDownload
        case .twenty:
            return .twentyDownloads
        case .oneHundred:
            return .oneHundredDownloads
        case .twoHundredFifty:
            return .twoHundredAndFiftyDownloads
        }
    }

    public static var matomoCategoryLocal: STCore.MatomoCategory? {
        return .settingsLocalDownloadLimit
    }

    public static var matomoCategoryGlobal: STCore.MatomoCategory? {
        return .settingsGlobalValidityPeriod
    }

    public func setSelected() async {
        @InjectService var settingsManager: AppSettingsManager
        _ = try? await settingsManager.setDownloadLimit(downloadLimit: self)
    }
}
