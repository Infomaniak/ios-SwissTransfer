/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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
import OSLog
import STCore

actor LocalUploadSessionStore {
    private var cache: [String: UploadSessionRequest] = [:]
    private let fileManager = FileManager.default
    private let uploadV2Manager: UploadV2Manager

    enum DomainError: Error {
        case failedToCreateStorageDirectory
        case sessionNotFound
    }

    private let storageDirectory: URL

    init(uploadV2Manager: UploadV2Manager) {
        self.uploadV2Manager = uploadV2Manager
        do {
            storageDirectory = try URL.appGroupTmpDirectory().appendingPathComponent("upload-sessions", isDirectory: true)
        } catch {
            fatalError("Couldn't create directory for upload sessions: \(error.localizedDescription)")
        }
    }

    func save(uuid: String, session: UploadSessionRequest) async throws {
        try createDirectoryIfNeeded()
        let fileURL = fileURL(for: uuid)

        do {
            let encodedSession = try await uploadV2Manager.encodeSessionRequest(request: session)
            try encodedSession.write(to: fileURL, atomically: true, encoding: .utf8)
            cache[uuid] = session
        } catch {
            Logger.general.error("Failed to save upload session \(uuid): \(error.localizedDescription)")
            throw error
        }
    }

    func get(uuid: String) async throws -> UploadSessionRequest? {
        if let cachedSession = cache[uuid] {
            return cachedSession
        }

        let fileURL = fileURL(for: uuid)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let encodedSession = try String(contentsOf: fileURL, encoding: .utf8)
            let session = try await uploadV2Manager.decodeSessionRequest(encodedString: encodedSession)
            cache[uuid] = session
            return session
        } catch {
            Logger.general.error("Failed to read upload session \(uuid): \(error.localizedDescription)")
            throw error
        }
    }

    func remove(uuid: String) throws {
        cache[uuid] = nil

        let fileURL = fileURL(for: uuid)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            Logger.general.error("Failed to remove upload session \(uuid): \(error.localizedDescription)")
            throw error
        }
    }

    func cleanupAll() throws {
        cache.removeAll()

        guard fileManager.fileExists(atPath: storageDirectory.path) else {
            return
        }

        do {
            try fileManager.removeItem(at: storageDirectory)
            Logger.general.info("Cleaned up all upload sessions")
        } catch {
            Logger.general.error("Failed to cleanup upload sessions: \(error.localizedDescription)")
            throw error
        }
    }

    private func fileURL(for uuid: String) -> URL {
        storageDirectory.appendingPathComponent("\(uuid).session")
    }

    private func createDirectoryIfNeeded() throws {
        guard !fileManager.fileExists(atPath: storageDirectory.path) else {
            return
        }

        do {
            try fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        } catch {
            Logger.general.error("Failed to create storage directory: \(error.localizedDescription)")
            throw DomainError.failedToCreateStorageDirectory
        }
    }
}
