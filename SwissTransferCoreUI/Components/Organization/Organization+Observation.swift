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

import Foundation
@preconcurrency import STCore
import SwiftUI

public extension View {
    func observeOrganizationChanges(swissTransferManager: SwissTransferInjection,
                                    onOrganizationsUpdated: (@MainActor ([STDOrganizationAccount]) -> Void)? = nil,
                                    onSelectedOrganizationUpdated: (@MainActor (STDOrganizationAccount?) -> Void)? = nil)
        -> some View {
        task {
            await withTaskGroup { group in
                group.addTask {
                    let organizationsFlow = swissTransferManager.accountManager.organizationAccountsForCurrentUser()

                    for await organizationAccounts in organizationsFlow {
                        guard !Task.isCancelled else { return }
                        await onOrganizationsUpdated?(organizationAccounts)
                    }
                }

                group.addTask {
                    let selectedOrganizationFlow = swissTransferManager.accountManager.selectedOrganizationAccount()
                    for await selectedOrganization in selectedOrganizationFlow {
                        guard !Task.isCancelled else { return }
                        await onSelectedOrganizationUpdated?(selectedOrganization)
                    }
                }
            }
        }
    }
}
