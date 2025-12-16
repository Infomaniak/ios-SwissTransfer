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

import STResources
import SwiftUI
import SwissTransferCore

public struct SizeLeftView: View {
    private let sizeOccupied: Int64

    private var remainingSize: Int64 {
        max(0, NewTransferConstants.maxFileSize - sizeOccupied)
    }

    private var filesSizeText: Text {
        return Text(
            STResourcesStrings.Localizable.transferSpaceLeft(
                remainingSize.formatted(.defaultByteCount)
            )
        )
    }

    public init(sizeOccupied: Int64) {
        self.sizeOccupied = sizeOccupied
    }

    public var body: some View {
        filesSizeText
            .monospacedDigit()
            .contentTransition(.numericText())
    }
}
