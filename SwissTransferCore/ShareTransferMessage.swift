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

public struct ShareTransferMessage: Transferable {
    let plainText: String
    let html: String

    public init(transferURL: URL) {
        let intro = STResourcesStrings.Localizable.messageShareIntro
        let footer = STResourcesStrings.Localizable.messageShareFooter
        let transferURLString = transferURL.absoluteString
        plainText = "\(intro)\n\(footer)\n\(transferURLString)"
        html = "<p>\(intro)</p><p>\(footer) <a href=\"\(transferURLString)\">\(transferURLString)</a></p>"
    }

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .html) { message in
            let document = """
            <!DOCTYPE html>
            <html>
            <head><meta charset="utf-8"></head>
            <body>\(message.html)</body>
            </html>
            """
            return Data(document.utf8)
        }
        .suggestedFileName("swisstransfer_link.html")
        ProxyRepresentation(exporting: \.plainText)
//        ProxyRepresentation { message in
//            message.plainText
//        }
    }
}
