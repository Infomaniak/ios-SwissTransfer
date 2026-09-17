/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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
import InfomaniakCoreSwiftUI
import STCore
import STResources
import SwiftUI

public struct OrganizationListView: View {
    @EnvironmentObject private var mainViewState: MainViewState

    let selectedOrganization: Binding<STDOrganizationAccount?>

    @State private var organizations: [STDOrganizationAccount] = []

    public init(selectedOrganization: Binding<STDOrganizationAccount?>) {
        self.selectedOrganization = selectedOrganization
    }

    public var body: some View {
        VStack {
            ForEach(organizations, id: \.id) { organization in
                OrganizationCellView(organization: organization, isSelected: organization.id == selectedOrganization.wrappedValue?.id) {
                    selectedOrganization.wrappedValue = organization
                }
            }
        }
        .padding(.horizontal, value: .medium)
        .task {
            let organizationsFlow: SkieSwiftFlow<[STDOrganizationAccount]> = mainViewState.swissTransferManager.accountManager.organizationAccountsForCurrentUser()

            for await value in organizationsFlow {
                organizations = value
            }
        }
    }
}
