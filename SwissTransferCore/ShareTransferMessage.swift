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

import LinkPresentation
import STResources
import UIKit

public final class ShareTransferMessage: NSObject, UIActivityItemSource {
    private static let urlOnlyActivityTypes: Set<UIActivity.ActivityType> = [
        .airDrop,
        .copyToPasteboard,
        .addToReadingList
    ]

    let url: URL
    let text: String

    public init(transferURL: URL) {
        url = transferURL
        text = [
            STResourcesStrings.Localizable.messageShareIntro,
            STResourcesStrings.Localizable.messageShareFooter,
            transferURL.absoluteString
        ].joined(separator: "\n")
        super.init()
    }

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        url
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        if let activityType, Self.urlOnlyActivityTypes.contains(activityType) {
            return url
        }
        return text
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        STResourcesStrings.Localizable.subjectShare
    }

    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = Constants.appName
        metadata.url = url
        metadata.originalURL = url
        return metadata
    }
}
