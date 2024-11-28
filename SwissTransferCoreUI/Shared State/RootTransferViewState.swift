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

import STCore
import SwiftUI

public enum RootTransferViewType {
    case newTransfer
    case uploadProgress(NewUploadSession)
    case error
    case success(String)
}

public final class RootTransferViewState: ObservableObject {
    @Published public var state = RootTransferViewType.newTransfer

    public init() {}
}

public final class RootTransferViewModel: ObservableObject {
    @Published public var transferType = TransferType.qrCode
    @Published public var authorEmail = ""
    @Published public var recipientEmail = ""
    @Published public var message = ""
    @Published public var password = ""
    @Published public var validityPeriod = ValidityPeriod.thirty
    @Published public var downloadLimit = DownloadLimit.twoHundredFifty
    @Published public var emailLanguage = EmailLanguage.french

    public init() {}
}
