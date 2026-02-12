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
import SwiftUI

public protocol TabBarAvatarIconProvidable {
    @MainActor func render(user: UserProfile, loadedImage: UIImage?, size: CGFloat) -> Image?
}

public struct TabBarAvatarIconProvider: TabBarAvatarIconProvidable {
    @MainActor public func render(user: UserProfile, loadedImage: UIImage?, size: CGFloat = 24) -> Image? {
        let view = avatarView(user: user, loadedImage: loadedImage, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 4
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage.withRenderingMode(.alwaysOriginal))
    }

    @MainActor @ViewBuilder
    private func avatarView(user: UserProfile, loadedImage: UIImage?, size: CGFloat) -> some View {
        if let loadedImage {
            Image(uiImage: loadedImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            InitialsView(
                initials: NameFormatter(fullName: user.displayName).initials,
                backgroundColor: Color.backgroundColor(from: user.email.hash),
                foregroundColor: Color.white,
                size: 24
            )
        }
    }
}
