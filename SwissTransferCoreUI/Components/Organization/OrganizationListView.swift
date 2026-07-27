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
    let selectedOrganization: Binding<STDOrganizationAccount?>
    let organizations: [STDOrganizationAccount]

    public init(selectedOrganization: Binding<STDOrganizationAccount?>, organizations: [STDOrganizationAccount]) {
        self.selectedOrganization = selectedOrganization
        self.organizations = organizations
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: IKPadding.micro) {
                ForEach(organizations, id: \.self) { orga in
                    OrganizationCellView(organization: orga, isSelected: orga.id == selectedOrganization.wrappedValue?.id) {
                        selectedOrganization.wrappedValue = orga
                    }

                    if orga.id != organizations.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, value: .medium)
        }
    }
}
