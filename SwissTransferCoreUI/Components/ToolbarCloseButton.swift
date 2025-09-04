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

import STResources
import SwiftUI

public struct ToolbarCloseButton: View {
    let completion: () -> Void

    public init(dismiss: DismissAction) {
        completion = dismiss.callAsFunction
    }

    public init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .close, action: completion)
        } else {
            Button(action: completion) {
                Label(STResourcesStrings.Localizable.contentDescriptionButtonClose, systemImage: "xmark")
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ToolbarCloseButton(completion: {})
}
