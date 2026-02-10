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
import InfomaniakCore
import SwiftUI

@MainActor
public class AvatarImageLoader: ObservableObject {
    @Published public var loadedImage: UIImage?
    @Published public var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    public init() {}

    public func loadAvatar(from urlString: String?) async {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                loadedImage = image
            }
        } catch {
            // Silently fail, keep initials as fallback
        }
    }
}
