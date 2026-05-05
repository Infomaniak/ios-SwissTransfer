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

import InfomaniakCore
import InfomaniakCoreSwiftUI
import NukeUI
import SwiftUI

public struct AvatarView: View {
    let user: UserProfile
    private let avatarSize: CGFloat

    public init(user: UserProfile, avatarSize: CGFloat = 80) {
        self.user = user
        self.avatarSize = avatarSize
    }

    public var body: some View {
        if let rawAvatarURL = user.avatar,
           let avatarURL = URL(string: rawAvatarURL) {
            LazyImage(request: ImageRequest(url: avatarURL)) { state in
                if let image = state.image {
                    AvatarImage(image: image, size: avatarSize)
                } else {
                    initialsView
                }
            }
        } else {
            initialsView
        }
    }

    private var initialsView: some View {
        InitialsView(
            initials: NameFormatter(fullName: user.displayName).initials,
            backgroundColor: Color.backgroundColor(from: user.email.hash),
            foregroundColor: Color.white,
            size: avatarSize
        )
    }
}
