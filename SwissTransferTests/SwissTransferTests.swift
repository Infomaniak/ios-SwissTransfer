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
@testable import SwissTransferCoreUI
import XCTest

@MainActor
final class SwissTransferTests: XCTestCase {
    override func tearDown() async throws {
        let newTransferManager = NewTransferFileManager(shouldDoInitialClean: true)
        await NewTransferFileManager.cleanTmpDir(type: .all)
    }

    func testDestinationURL() {
        do {
            // GIVEN
            let newTransferManager = NewTransferFileManager()
            let fileName = "my-file.txt"
            let sourcePath = URL(string: "http://my-url.com/\(fileName)")!
            let expectedResult = try URL.tmpUploadDirectory().appendingPathComponent(fileName)

            // WHEN
            let result = try newTransferManager.destinationURLFor(source: sourcePath)

            // THEN
            XCTAssertEqual(result, expectedResult)
        } catch {
            XCTFail("Error creating destination URL")
        }
    }

    func testRenameDestinationURL() {
        do {
            // GIVEN
            let newTransferManager = NewTransferFileManager()
            let sourcePath = URL(string: "http://my-url.com/my-file.txt")!
            let tmpDirectory = try URL.tmpUploadDirectory()
            let expectedResult = tmpDirectory.appendingPathComponent("my-file(1).txt")
            let firstURL = tmpDirectory.appendingPathComponent("my-file.txt", conformingTo: .text)
            FileManager.default.createFile(atPath: firstURL.path(), contents: nil)

            // WHEN
            let result = try newTransferManager.destinationURLFor(source: sourcePath)

            // THEN
            XCTAssertEqual(result, expectedResult)
        } catch {
            XCTFail("Error creating destination URL")
        }
    }
}
