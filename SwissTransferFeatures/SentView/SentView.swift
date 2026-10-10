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

import DesignSystem
import InfomaniakDI
import STCore
import STResources
import STTransferList
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct SentView: View {
    @LazyInjectService private var accountManager: SwissTransferCore.AccountManager
    @Environment(\.currentSession) private var currentSession
    @Environment(\.isCompactWindow) private var isCompactWindow
    @EnvironmentObject private var transferManager: TransferManager
    @EnvironmentObject private var mainViewState: MainViewState

    private let direction = TransferDirection.sent

    @State private var hasTransfers = false

    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            TransferList(transferManager: transferManager, direction: direction, matomoCategory: .importFileFromSent) {
                SentEmptyView()
            }
            .matomoView(view: .sent)
        }
        .task {
            for await value in transferManager.hasAccountTransferFlow() {
                withAnimation {
                    hasTransfers = value.boolValue
                }
            }
        }
        .safeAreaInset(edge: .top, alignment: .leading) {
            if hasTransfers {
                VStack(alignment: .leading) {
                    if isCompactWindow {
                        Text(direction.title)
                            .font(.ST.title)
                            .foregroundStyle(Color.ST.textPrimary)
                    }

                    OrganizationSelectorView()
                }
                .padding(.horizontal, value: .medium)
                .padding(.top, value: .medium)
                .listRowInsets(EdgeInsets(.zero))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.ST.background)
            }
        }
    }
}

#Preview("SentView") {
    SentView()
}
