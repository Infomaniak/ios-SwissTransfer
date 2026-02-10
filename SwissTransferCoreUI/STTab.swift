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

import InfomaniakCore
import InfomaniakCoreSwiftUI
import NukeUI
import STResources
import SwiftUI

public enum STTab: CaseIterable, Identifiable, Codable, Hashable {
    case sentTransfers
    case receivedTransfers
    case account(UserProfile?)

    public var id: String {
        switch self {
        case .sentTransfers:
            return "sentTransfers"
        case .receivedTransfers:
            return "receivedTransfers"
        case .account(let user):
            if let user {
                return "\(user.id)"
            } else {
                return "account"
            }
        }
    }

    @MainActor public var title: String {
        switch self {
        case .sentTransfers:
            return STResourcesStrings.Localizable.sentTitle
        case .receivedTransfers:
            return STResourcesStrings.Localizable.receivedTitle
        case .account:
            return STResourcesStrings.Localizable.titleMyAccount
        }
    }

    @MainActor public func icon(avatarImage: UIImage? = nil) -> Image {
        switch self {
        case .sentTransfers:
            return STResourcesAsset.Images.arrowUpCircle.swiftUIImage
        case .receivedTransfers:
            return STResourcesAsset.Images.arrowDownCircle.swiftUIImage
        case .account(let user):
            if let user {
                return TabBarAvatarIcon.render(user: user, loadedImage: avatarImage)
                    ?? STResourcesAsset.Images.user.swiftUIImage
            } else {
                return STResourcesAsset.Images.user.swiftUIImage
            }
        }
    }

    public static var allCases: [STTab] {
        [.sentTransfers, .receivedTransfers, .account(nil)]
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userProfile
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "sentTransfers":
            self = .sentTransfers
        case "receivedTransfers":
            self = .receivedTransfers
        case "account":
            let userProfile = try container.decodeIfPresent(UserProfile.self, forKey: .userProfile)
            self = .account(userProfile)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown STTab type: \(type)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .sentTransfers:
            try container.encode("sentTransfers", forKey: .type)
        case .receivedTransfers:
            try container.encode("receivedTransfers", forKey: .type)
        case .account(let userProfile):
            try container.encode("account", forKey: .type)
            try container.encodeIfPresent(userProfile, forKey: .userProfile)
        }
    }

    @MainActor public func label(avatarImage: UIImage? = nil) -> Label<Text, Image> {
        Label(title: { Text(title) }, icon: { icon(avatarImage: avatarImage) })
    }
}
