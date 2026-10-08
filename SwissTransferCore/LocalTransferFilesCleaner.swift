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
import InfomaniakDI
import OSLog
import STCore

struct LocalTransferFilesCleaner {
    func cleanOrphanedLocalContainers(using transferManager: TransferManager) async {
        guard let downloadsDirectory = try? URL.tmpDownloadsDirectory(),
              let folderNames = try? FileManager.default.contentsOfDirectory(atPath: downloadsDirectory.path())
        else { return }

        for folderName in folderNames {
            let folderURL = downloadsDirectory.appendingPathComponent(folderName)
            guard (try? folderURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else { continue }
            do {
                if try await transferManager.getTransferByUUID(transferUUID: folderName) == nil {
                    try FileManager.default.removeItem(at: folderURL)
                }
            } catch {
                Logger.general.error("Failed to clean downloaded files for transfer \(folderName): \(error)")
            }
        }
    }
}
