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

import InfomaniakCoreUI
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

public struct NewTransferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var newTransferManager: NewTransferManager

    public init(urls: [URL]) {
        _newTransferManager = StateObject(wrappedValue: NewTransferManager(urls: urls))
    }

    public var body: some View {
        NavigationStack {
            FileListView(parentFolder: nil)
                .floatingContainer {
                    VStack(spacing: 0) {
                        AddFilesMenuView { _ in } label: {
                            Label(
                                title: { Text(STResourcesStrings.Localizable.buttonAddFiles) },
                                icon: { STResourcesAsset.Images.plus.swiftUIImage }
                            )
                        }
                        .buttonStyle(.ikBorderless)

                        NavigationLink {
                            NewTransferTypeView()
                        } label: {
                            Text(STResourcesStrings.Localizable.buttonNext)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.ikBorderedProminent)
                    }
                    .ikButtonFullWidth(true)
                    .controlSize(.large)
                }
                .stNavigationBarNewTransfer(title: STResourcesStrings.Localizable.importFilesScreenTitle)
                .stNavigationBarStyle()
                .navigationDestination(for: DisplayableFile.self) { file in
                    FileListView(parentFolder: file)
                        .stNavigationBarNewTransfer(title: file.name)
                        .stNavigationBarStyle()
                }
        }
        .environment(\.dismissModal) {
            dismiss()
        }
        .environmentObject(newTransferManager)
    }
}

#Preview {
    NewTransferView(urls: [])
}
