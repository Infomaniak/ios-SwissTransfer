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

import Combine
import InfomaniakDI
import STCore

public protocol UploadCancellable: Sendable {
    func cancelUploads() async
}

public final class DummyUploadCancellable: UploadCancellable {
    public func cancelUploads() async {}
    public init() {}
}

public struct CurrentUploadContainer: Identifiable, Sendable {
    public var id: String { uuid }
    public let uuid: String
    public let uploadsCancellable: UploadCancellable

    public init(uuid: String, uploadsCancellable: UploadCancellable) {
        self.uuid = uuid
        self.uploadsCancellable = uploadsCancellable
    }
}

extension CurrentUploadContainer: Cancellable {
    public func cancel() {
        Task {
            await uploadsCancellable.cancelUploads()

            @InjectService var injection: SwissTransferInjection
            let uploadManager = injection.uploadManager
            try? await uploadManager.cancelUploadSession(uuid: uuid)
        }
    }
}
