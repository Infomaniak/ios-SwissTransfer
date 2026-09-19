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
import MyKSuite
import STCore
import SwiftUI

public struct OrganizationSelectorView: View {
    @EnvironmentObject private var mainViewState: MainViewState

    @State private var isShowingOrganizationList = false
    @State private var selectedOrganization: STDOrganizationAccount?

    public init() {}

    public var body: some View {
        ZStack {
            if let selectedOrganization {
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
        .observeOrganizationChanges(swissTransferManager: mainViewState.swissTransferManager,
                                    onOrganizationsUpdated: nil) { selectedOrganization in
            self.selectedOrganization = selectedOrganization
        }
        .stFloatingPanel(isPresented: $isShowingOrganizationList) {
            OrganizationListView()
        }
    }
}
