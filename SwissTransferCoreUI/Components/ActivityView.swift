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
import SwiftUI

public struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [FileShareModel]

    public init(sharedFileURLs: [URL]) {
        activityItems = sharedFileURLs.compactMap { try? FileShareModel(url: $0) }
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}

    class FileShareModel: NSObject, UIActivityItemSource {
        let url: URL
        let data: Data
        let title: String

        init(url: URL) throws {
            self.url = url
            title = url.lastPathComponent
            data = try Data(contentsOf: url)
            super.init()
        }

        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            data
        }

        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            data
        }

        func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
            let metadata = LPLinkMetadata()
            metadata.title = title
            metadata.url = url
            metadata.originalURL = url
            metadata.iconProvider = NSItemProvider(contentsOf: url)
            return metadata
        }
    }
}
