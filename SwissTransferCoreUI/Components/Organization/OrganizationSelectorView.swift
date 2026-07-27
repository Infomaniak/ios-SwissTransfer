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
import STCore
import SwiftUI

public struct OrganizationSelectorView: View {
    @Binding var isShowingOrganizationList: Bool

    let selectedOrganization: STDOrganizationAccount

    public init(isShowingOrganizationList: Binding<Bool>, selectedOrganization: STDOrganizationAccount) {
        _isShowingOrganizationList = isShowingOrganizationList
        self.selectedOrganization = selectedOrganization
    }

    public var body: some View {
        Button {
            isShowingOrganizationList = true
        } label: {
            HStack {
                OrganizationAvatarView(organization: selectedOrganization, avatarSize: IKIconSize.large.rawValue)
                Text(selectedOrganization.name)
                Image(systemName: "chevron.down")
            }
        }
        .buttonStyle(.plain)
    }
}
