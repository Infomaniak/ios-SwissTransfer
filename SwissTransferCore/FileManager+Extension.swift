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

public extension FileManager {
    /// Find a valid name if a file/folder already exist with the same name
    static func destinationURLFor(source: URL, to destination: URL) throws -> URL {
        let allFiles = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: nil)
            .map(\.lastPathComponent)

        let shortName = source.deletingPathExtension().lastPathComponent
        var increment = 0
        var testName = source.lastPathComponent
        while allFiles.contains(where: { $0 == testName }) {
            increment += 1
            testName = shortName.appending("(\(increment))")
            if !source.pathExtension.isEmpty {
                testName.append(".\(source.pathExtension)")
            }
        }
        return destination.appending(path: testName)
    }
}
