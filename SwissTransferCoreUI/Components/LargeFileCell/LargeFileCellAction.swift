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

public protocol LargeFileCellAction {
    var action: (any DisplayableFile) -> Void { get }
    func icon(for file: any DisplayableFile, transferUUID: String?) -> Image
}

public extension LargeFileCellAction {
    func callAsFunction(file: any DisplayableFile) {
        action(file)
    }
}

public struct RemoveFileAction: LargeFileCellAction {
    public let action: (any DisplayableFile) -> Void

    public func icon(for file: any DisplayableFile, transferUUID: String?) -> Image {
        Image(systemName: "xmark")
    }

    public init(action: @escaping (any DisplayableFile) -> Void) {
        self.action = action
    }
}

public struct DownloadFileAction: LargeFileCellAction {
    public var action: (any DisplayableFile) -> Void

    public func icon(for file: any DisplayableFile, transferUUID: String?) -> Image {
        guard file.existsLocally(transferUUID: transferUUID) else {
            return STResourcesAsset.Images.arrowDownLine.swiftUIImage
        }

        return STResourcesAsset.Images.check.swiftUIImage
    }

    public init(action: @escaping (any DisplayableFile) -> Void) {
        self.action = action
    }
}
