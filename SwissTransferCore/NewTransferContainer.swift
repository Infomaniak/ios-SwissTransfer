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

import Foundation

public enum NewTransferContainerContent: Equatable {
    case importedItems([ImportedItem])
    case shareExtensionContinuing(String)
}

public struct NewTransferContainer: Identifiable, Equatable {
    public let id: Int
    public let content: NewTransferContainerContent

    public init(importedItems: [ImportedItem]) {
        id = importedItems.hashValue
        content = .importedItems(importedItems)
    }

    public init(localSessionUUID: String) {
        id = localSessionUUID.hashValue
        content = .shareExtensionContinuing(localSessionUUID)
    }
}
