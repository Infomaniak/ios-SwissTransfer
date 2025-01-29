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
import STCore

public extension SharedApiUrlCreator {
    func importFromShareExtensionURL(localImportUUID: String) throws -> URL {
        guard let host = URL(string: createUploadContainerUrl)?.host() else {
            fatalError("Couldn't create host from URL")
        }
        var urlComponents = URLComponents(string: "https://\(host)/import")
        urlComponents?.queryItems = [URLQueryItem(name: "uuid", value: localImportUUID)]

        guard let importURL = urlComponents?.url else {
            throw URLError(.badURL)
        }

        return importURL
    }
}
