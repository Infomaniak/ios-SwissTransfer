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
    @EnvironmentObject private var transferManager: TransferManager

    private let direction = TransferDirection.sent

    @State private var selectedOrganization: STDOrganizationAccount?
    @State private var organizations: [STDOrganizationAccount] = []
    @State private var isShowingOrganizationList = false

    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(direction.title)
                    .font(.ST.title)
                    .foregroundStyle(Color.ST.textPrimary)

                if let selectedOrganization {
                    OrganizationSelectorView(
                        isShowingOrganizationList: $isShowingOrganizationList,
                        selectedOrganization: selectedOrganization
                    )
                }
            }
            .padding(.horizontal, value: .medium)
            .padding(.top, value: .medium)
            .listRowInsets(EdgeInsets(.zero))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.ST.background)

            TransferList(transferManager: transferManager, direction: direction, matomoCategory: .importFileFromSent) {
                SentEmptyView()
            }
            .matomoView(view: .sent)
        }
        .task {
            guard let organizationAccounts = await accountManager.organizationAccounts() else { return }
            organizations = organizationAccounts
        }
        .task {
            guard let selectedOrganization = await accountManager.selectedOrganization() else { return }
            self.selectedOrganization = selectedOrganization
        }
        .onChange(of: selectedOrganization) { newValue in
            guard let newValue else { return }
            Task {
                await accountManager.switchToOrganization(organizationId: Int(newValue.id))
            }
            isShowingOrganizationList = false
        }
        .stFloatingPanel(isPresented: $isShowingOrganizationList) {
            OrganizationListView(selectedOrganization: $selectedOrganization, organizations: organizations)
        }
    }
}

#Preview("SentView") {
    SentView()
}
