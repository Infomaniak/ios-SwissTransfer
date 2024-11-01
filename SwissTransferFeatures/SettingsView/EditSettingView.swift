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

struct EditCellDatom: Hashable, Equatable {
    let label: String
    let action: () -> Void
    let index: Int
    let leftIconAsset: STResourcesImages?

    init(label: String, action: @escaping () -> Void, index: Int, leftIconAsset: STResourcesImages? = nil) {
        self.label = label
        self.action = action
        self.index = index
        self.leftIconAsset = leftIconAsset
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.label == rhs.label
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}

// TODO: Refactor
struct EditSettingViewDatasource {
    @LazyInjectService private var settingsManager: AppSettingsManager

    let source: SettingDetailUi

    var title: String {
        switch source {
        case .theme:
            return STResourcesStrings.Localizable.settingsThemeTitle
        case .validityPeriod:
            return STResourcesStrings.Localizable.settingsValidityPeriodTitle
        case .downloadLimit:
            return STResourcesStrings.Localizable.settingsDownloadsLimitTitle
        case .emailLanguage:
            return STResourcesStrings.Localizable.settingsEmailLanguageTitle
        default:
            return ""
        }
    }

    func validityPeriod(index: Int) -> ValidityPeriod {
        switch index {
        case 0:
            ValidityPeriod.thirty
        case 1:
            ValidityPeriod.fifteen
        case 2:
            ValidityPeriod.seven
        default:
            ValidityPeriod.one
        }
    }

    func theme(index: Int) -> STCore.Theme {
        switch index {
        case 1:
            .light
        case 2:
            .dark
        default:
            .system
        }
    }

    func downloadLimit(index: Int) -> STCore.DownloadLimit {
        switch index {
        case 1:
            .oneHundred
        case 2:
            .twenty
        case 3:
            .one
        default:
            .twoHundredFifty
        }
    }

    func emailLanguage(index: Int) -> EmailLanguage {
        switch index {
        case 1:
            .french
        case 2:
            .german
        case 3:
            .italian
        case 4:
            .spanish
        default:
            .english
        }
    }

    // TODO: Not a fan of passing an offset here. Just for demo. Could use generics but would add complexity.
    func action(index: Int) {
        Task {
            switch source {
            case .theme:
                _ = try? await settingsManager.setTheme(theme: theme(index: index))
            case .validityPeriod:
                _ = try? await settingsManager.setValidityPeriod(validityPeriod: validityPeriod(index: index))
            case .downloadLimit:
                _ = try? await settingsManager.setDownloadLimit(downloadLimit: downloadLimit(index: index))
            case .emailLanguage:
                _ = try? await settingsManager.setEmailLanguage(emailLanguage: emailLanguage(index: index))
            default:
                assertionFailure("unexpected")
            }
        }
    }

    private func datomFactory(label: [String]) -> [EditCellDatom] {
        var buffer = [EditCellDatom]()
        for (index, value) in label.enumerated() {
            let lambda = {
                action(index: index)
            }
            buffer.append(EditCellDatom(label: value, action: lambda, index: index))
        }
        return buffer
    }

    var cellsInterlinked: [EditCellDatom] {
        switch source {
        case .theme:
            return datomFactory(label: [Theme.system.localized,
                                        Theme.light.localized,
                                        Theme.dark.localized])
        case .validityPeriod:
            return datomFactory(label: ["30 days", "15 days", "7 days", "1 day"])
        case .downloadLimit:
            return datomFactory(label: ["250", "100", "20", "1"])
        case .emailLanguage:
            return datomFactory(label: [STResourcesStrings.Localizable.settingsEmailLanguageValueEnglish,
                                        STResourcesStrings.Localizable.settingsEmailLanguageValueFrench,
                                        STResourcesStrings.Localizable.settingsEmailLanguageValueGerman,
                                        STResourcesStrings.Localizable.settingsEmailLanguageValueItalian,
                                        STResourcesStrings.Localizable.settingsEmailLanguageValueSpanish])
        default:
            return []
        }
    }
}

struct EditSettingView: View {
    @EnvironmentObject private var mainViewState: MainViewState
    @Environment(\.presentationMode) private var presentationMode

    @LazyInjectService var settingsManager: AppSettingsManager

    @StateObject var appSettings: FlowObserver<AppSettings>

    let source: SettingDetailUi

    let datasource: EditSettingViewDatasource

    public init(source: SettingDetailUi) {
        self.source = source
        datasource = EditSettingViewDatasource(source: source)

        @InjectService var settingsManager: AppSettingsManager
        _appSettings = StateObject(wrappedValue: FlowObserver(flow: settingsManager.appSettings))
    }

    var body: some View {
        List(selection: $mainViewState.selectedDestination) {
            Section(header: Text(datasource.title)) {
                ForEach(datasource.cellsInterlinked, id: \.self) { item in
                    EditSettingsView(leftIconAsset: nil, label: item.label) {
                        presentationMode.wrappedValue.dismiss()
                        item.action()
                    }
                }
            }
        }
    }
}

#Preview {
    EditSettingView(source: .theme)
}
