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

import DesignSystem
import InfomaniakCoreSwiftUI
import SwiftUI

public extension View {
    func stCustomAlert<Item, Content>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View
        where Item: Identifiable, Content: View {
        customAlert(
            item: item,
            backgroundColor: .ST.modalBackground,
            content: content
        )
    }

    func stCustomAlert<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        customAlert(
            isPresented: isPresented,
            backgroundColor: .ST.modalBackground,
            content: content
        )
    }
}

public extension View {
    func stDiscoveryPresenter<ModalContent: View>(
        isPresented: Binding<Bool>,
        bottomPadding: CGFloat = IKPadding.medium,
        @ViewBuilder modalContent: @escaping () -> ModalContent
    ) -> some View {
        discoveryPresenter(
            isPresented: isPresented,
            bottomPadding: bottomPadding,
            alertBackgroundColor: .ST.modalBackground,
            sheetBackgroundColor: .ST.modalBackground,
            modalContent: modalContent
        )
    }
}

public extension View {
    func stFloatingPanel<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        bottomPadding: CGFloat = IKPadding.medium,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        floatingPanel(
            isPresented: isPresented,
            title: title,
            backgroundColor: .ST.modalBackground,
            bottomPadding: bottomPadding,
            content: content
        )
    }

    func stFloatingPanel<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        title: String? = nil,
        bottomPadding: CGFloat = IKPadding.medium,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        floatingPanel(
            item: item,
            backgroundColor: .ST.modalBackground,
            title: title,
            bottomPadding: bottomPadding,
            content: content
        )
    }
}
