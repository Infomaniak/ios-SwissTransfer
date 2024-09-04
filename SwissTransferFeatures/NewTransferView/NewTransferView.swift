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
    @StateObject private var sheetPresenter: SheetPresenter
    @StateObject private var newTransferManager: NewTransferManager

    public init(isPresented: Binding<Bool>) {
        _sheetPresenter = StateObject(wrappedValue: SheetPresenter(isPresented: isPresented))
        _newTransferManager = StateObject(wrappedValue: NewTransferManager())
    }

    private var filesSize: Int64 {
        newTransferManager.uploadFiles.map { $0.size }.reduce(0, +)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(
                        "\(STResourcesStrings.Localizable.filesCount(newTransferManager.uploadFiles.count)) · \(filesSize.formatted(.defaultByteCount))"
                    )

                    LazyVGrid(
                        columns: columns,
                        alignment: .center,
                        spacing: 16,
                        pinnedViews: []
                    ) {
                        ForEach(newTransferManager.uploadFiles) { file in
                            LargeThumbnailView(
                                fileName: file.url.lastPathComponent,
                                fileSize: file.size,
                                url: file.url,
                                mimeType: file.mimeType
                            )
                        }
                    }
                    Spacer()
                }
                .padding(value: .medium)
            }
            .floatingContainer {
                VStack(spacing: 0) {
                    AddFilesMenuView()

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
        }
        .environmentObject(sheetPresenter)
        .environmentObject(newTransferManager)
    }
}

#Preview {
    NewTransferView(isPresented: .constant(true))
}
