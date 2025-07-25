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

import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import STCore
import SwiftUI
import SwissTransferCore

public enum FloatingActionButtonStyle {
    case newTransfer
    case firstTransfer
}

struct FloatingActionButtonModifier: ViewModifier {
    @Environment(\.isRunningInAppClip) private var isRunningInAppClip

    @Binding var selection: [ImportedItem]

    let isShowing: Bool
    let style: FloatingActionButtonStyle
    let matomoCategory: MatomoCategory

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                if isShowing && !isRunningInAppClip {
                    Group {
                        switch style {
                        case .newTransfer:
                            NewTransferButton(selection: $selection, matomoCategory: matomoCategory)
                        case .firstTransfer:
                            FirstTransferButton(selection: $selection, style: .small, matomoCategory: matomoCategory)
                        }
                    }
                    .padding([.trailing, .bottom], value: .medium)
                }
            }
    }
}

public extension View {
    func floatingActionButton(isShowing: Bool = true, selection: Binding<[ImportedItem]>,
                              style: FloatingActionButtonStyle, matomoCategory: MatomoCategory) -> some View {
        modifier(FloatingActionButtonModifier(
            selection: selection,
            isShowing: isShowing,
            style: style,
            matomoCategory: matomoCategory
        ))
    }
}
