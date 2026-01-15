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

import STCore
import SwiftUI

public class MultipleSelectionManager: ObservableObject {
    @Published public var isEnabled = false
    @Published public var selectedItems = Set<FileUi>()
    public var allSelectable = [FileUi]()

    public init() {}

    public func isSelected(file: FileUi) -> Bool {
        return selectedItems.contains(file)
    }

    public func toggleSelection(of file: FileUi) {
        withAnimation(.default.speed(2)) {
            if selectedItems.contains(file) {
                selectedItems.remove(file)
            } else {
                selectedItems.insert(file)
            }

            updateEnableState()
        }
    }

    public func selectAll() {
        selectAll(files: allSelectable)
    }

    private func selectAll(files: [FileUi]) {
        if files.count == selectedItems.count {
            selectedItems.removeAll()
            isEnabled = false
        } else {
            for file in files {
                selectedItems.insert(file)
            }
        }
    }

    public func disable() {
        selectedItems.removeAll()
        isEnabled = false
    }

    private func updateEnableState() {
        isEnabled = !selectedItems.isEmpty
    }
}
