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

import InfomaniakConcurrency
import OSLog
import QuickLookThumbnailing
import STCore
import SwiftUI

public struct ThumbnailProvider: Sendable {
    enum DomainError: Error {
        case invalidData
    }

    private let thumbnailsDirectory: URL?

    public init() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        thumbnailsDirectory = cacheURL?.appendingPathComponent("thumbnails")
    }

    private func thumbnailURLFor(fileUUID: String, transferUUID: String) -> URL? {
        guard let thumbnailsDirectory else { return nil }

        try? FileManager.default.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)

        let thumbnailURL = thumbnailsDirectory.appendingPathComponent("\(transferUUID)--\(fileUUID).jpeg")

        return thumbnailURL
    }

    public func generateThumbnailFor(fileUUID: String, transferUUID: String, fileURL: URL?, scale: CGFloat) async -> Image? {
        guard let thumbnailURL = thumbnailURLFor(fileUUID: fileUUID, transferUUID: transferUUID) else { return nil }

        if FileManager.default.fileExists(atPath: thumbnailURL.path(percentEncoded: false)),
           let uiImage = UIImage(contentsOfFile: thumbnailURL.path(percentEncoded: false)) {
            return Image(uiImage: uiImage)
        } else if let fileURL {
            try? await generateThumbnailFor(url: fileURL, scale: scale, destinationURL: thumbnailURL)
            if let uiImage = UIImage(contentsOfFile: thumbnailURL.path(percentEncoded: false)) {
                return Image(uiImage: uiImage)
            }
        }

        return nil
    }

    public func generateThumbnailFor(url fileURL: URL, scale: CGFloat, destinationURL: URL) async throws {
        let filePath = fileURL.path(percentEncoded: false)
        guard FileManager.default.fileExists(atPath: filePath) else {
            return
        }

        let uiImage: UIImage = try await generateThumbnail(fileURL: fileURL, scale: scale)

        guard let imageData = uiImage.jpegData(compressionQuality: 1) else {
            throw DomainError.invalidData
        }

        try imageData.write(to: destinationURL)

        Logger.general.debug("Wrote thumbnail to \(destinationURL.path(percentEncoded: true))")
    }

    public func generateTemporaryThumbnailsFor(uploadSession: SendableUploadSession, scale: CGFloat) async -> [(String, URL)] {
        let uuidsWithThumbnail: [(String, URL)] = await uploadSession.files.asyncCompactMap { file in
            guard let remoteFileUUID = file.remoteUploadFile?.uuid,
                  let generatedThumbnailURL = await generateTemporaryThumbnailFor(file: file, scale: scale)
            else {
                return nil
            }

            return (remoteFileUUID, generatedThumbnailURL)
        }

        return uuidsWithThumbnail
    }

    private func generateTemporaryThumbnailFor(file: SendableUploadFileSession, scale: CGFloat) async -> URL? {
        guard let fileLocalURL = URL(string: file.localPath) else { return nil }

        let tmpDirectoryURL = FileManager.default.temporaryDirectory.appending(path: "thumbnails", directoryHint: .isDirectory)

        do {
            try FileManager.default.createDirectory(at: tmpDirectoryURL, withIntermediateDirectories: true, attributes: nil)

            let tmpThumbnail = tmpDirectoryURL.appending(path: "\(UUID().uuidString).jpeg")

            try await generateThumbnailFor(url: fileLocalURL, scale: scale, destinationURL: tmpThumbnail)

            return tmpThumbnail
        } catch {
            return nil
        }
    }

    public func moveTemporaryThumbnails(uuidsWithThumbnail: [(String, URL)], transferUUID: String) {
        for (uuid, temporaryThumbnailURL) in uuidsWithThumbnail {
            guard let thumbnailURL = thumbnailURLFor(fileUUID: uuid, transferUUID: transferUUID) else {
                continue
            }

            try? FileManager.default.moveItem(at: temporaryThumbnailURL, to: thumbnailURL)
        }
    }

    private func generateThumbnail(fileURL: URL, scale: CGFloat) async throws -> UIImage {
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL,
            size: CGSize(width: 256, height: 256),
            scale: scale,
            representationTypes: .thumbnail
        )

        let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)

        return thumbnail.uiImage
    }

    public func generateThumbnail(fileURL: URL, scale: CGFloat) async throws -> Image {
        let uiImage: UIImage = try await generateThumbnail(fileURL: fileURL, scale: scale)
        return Image(uiImage: uiImage)
    }
}
