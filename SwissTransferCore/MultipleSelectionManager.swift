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

@MainActor
public class MultipleSelectionManager: ObservableObject {
    @Published public var selectedItems = Set<FileUi>()

    public var isEnabled: Bool {
        !selectedItems.isEmpty
    }

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    public init() {}

    public func isSelected(file: FileUi) -> Bool {
        return selectedItems.contains(file)
    }

    public func toggleMultipleSelection(of file: FileUi) {
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()

        toggleSelection(of: file)
    }

    public func toggleSelection(of file: FileUi) {
        withAnimation(.default.speed(2)) {
            if selectedItems.contains(file) {
                selectedItems.remove(file)
            } else {
                selectedItems.insert(file)
            }
        }
    }

    public func selectAll(files: [FileUi]?) {
        guard let files else { return }

        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred(intensity: 0.6)

        if files.count == selectedItems.count {
            selectedItems.removeAll()
        } else {
            selectedItems.formUnion(files)
        }
    }

    public func disable() {
        withAnimation {
            selectedItems.removeAll()
        }
    }
}
