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
import PhotosUI
import STResources
import SwiftUI
import SwissTransferCore

public struct AddFilesMenuView<Content: View>: View {
    @State private var showImportFile = false
    @State private var showCamera = false
    @State private var showLibrary = false

    @State private var selectedPhotos: [PhotosPickerItem] = []

    private let completion: ([URL]) -> Void
    private let label: () -> Content

    public init(completion: @escaping ([URL]) -> Void, @ViewBuilder label: @escaping () -> Content) {
        self.completion = completion
        self.label = label
    }

    public var body: some View {
        Menu {
            Button {
                showImportFile = true
            } label: {
                Label(
                    title: { Text(STResourcesStrings.Localizable.transferUploadSourceChoiceFiles) },
                    icon: { STResourcesAsset.Images.folder.swiftUIImage }
                )
            }
            Button {
                showLibrary = true
            } label: {
                Label(
                    title: { Text(STResourcesStrings.Localizable.transferUploadSourceChoiceGallery) },
                    icon: { STResourcesAsset.Images.image.swiftUIImage }
                )
            }
            Button {
                // TODO: - Open Camera
            } label: {
                Label(
                    title: {
                        Text(STResourcesStrings.Localizable.transferUploadSourceChoiceCamera)
                    },
                    icon: { STResourcesAsset.Images.camera.swiftUIImage }
                )
            }
        } label: {
            label()
        }
        .photosPicker(isPresented: $showLibrary, selection: $selectedPhotos, photoLibrary: .shared())
        .onChange(of: selectedPhotos) { _ in
            guard !selectedPhotos.isEmpty else { return }
            Task {
                var photoList = [LibraryContent]()
                // Save photos
                for photo in selectedPhotos {
                    do {
                        guard let newFile = try await photo.loadTransferable(type: LibraryContent.self) else { continue }
                        photoList.append(newFile)
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }

                let urls = photoList.map {
                    $0.url
                }
                completion(urls)
            }
        }
        .fileImporter(
            isPresented: $showImportFile,
            allowedContentTypes: [.item, .folder],
            allowsMultipleSelection: true,
            onCompletion: { result in
                switch result {
                case .success(let urls):
                    completion(urls)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        )
    }
}

#Preview {
    AddFilesMenuView { _ in } label: { EmptyView() }
}
