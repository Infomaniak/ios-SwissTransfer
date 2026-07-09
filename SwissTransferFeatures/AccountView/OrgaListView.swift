/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

struct OrgaListView: View {
    let selectedOrganization: STDOrganizationAccount?
    let organizations: [STDOrganizationAccount]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: IKPadding.micro) {
                ForEach(organizations, id: \.self) { orga in
                    OrgaCellView(organization: orga, isSelected: orga.id == selectedOrganization?.id)
                }
            }
            .padding(.horizontal, value: .medium)
        }
    }
}

// #Preview {
//    OrgaListView(selectedOrganization: <#STDOrganizationAccount#>, organizations: <#[STDOrganizationAccount]#>)
// }
