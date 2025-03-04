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
import InfomaniakCoreUIResources
import STResources
import SwiftUI

public struct UserFacingError: LocalizedError {
    public let errorDescription: String
    public let failureReason: String?
    public let helpAnchor: String?
    public let recoverySuggestion: String?

    public init(
        errorDescription: String,
        failureReason: String? = nil,
        helpAnchor: String? = nil,
        recoverySuggestion: String? = nil
    ) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.helpAnchor = helpAnchor
        self.recoverySuggestion = recoverySuggestion
    }
}

public extension UserFacingError {
    static let unknownError = UserFacingError(errorDescription: CoreUILocalizable.anErrorHasOccurred)
}

public struct UploadError: Error {
    public let title: String
    public let subtitle: String
    public let image: Image
    public let canRetry: Bool

    public init(
        title: String = STResourcesStrings.Localizable.uploadErrorTitle,
        subtitle: String = STResourcesStrings.Localizable.uploadErrorDescription,
        image: Image = STResourcesAsset.Images.ghostMagnifyingGlassQuestionMark.swiftUIImage,
        canRetry: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.canRetry = canRetry
    }
}
