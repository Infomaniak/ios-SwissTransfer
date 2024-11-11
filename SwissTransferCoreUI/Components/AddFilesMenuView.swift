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
import OSLog
import PhotosUI
import STResources
import SwiftUI
import SwissTransferCore

public struct AddFilesMenuView<Content: View>: View {
    @State private var isShowingImportFile = false
    @State private var isShowingCamera = false

    @State private var isShowingPhotoLibrary = false
    @State private var selectedPhotos: [PhotosPickerItem] = []

    private let completion: ([URL]) -> Void
    private let label: Content

    public init(completion: @escaping ([URL]) -> Void, @ViewBuilder label: () -> Content) {
        self.completion = completion
        self.label = label()
    }

    public var body: some View {
        Menu {
            Button {
                isShowingImportFile = true
            } label: {
                Label(
                    title: { Text(STResourcesStrings.Localizable.transferUploadSourceChoiceFiles) },
                    icon: { STResourcesAsset.Images.folder.swiftUIImage }
                )
            }
            Button {
                isShowingPhotoLibrary = true
            } label: {
                Label(
                    title: { Text(STResourcesStrings.Localizable.transferUploadSourceChoiceGallery) },
                    icon: { STResourcesAsset.Images.image.swiftUIImage }
                )
            }
            Button {
                isShowingCamera = true
            } label: {
                Label(
                    title: {
                        Text(STResourcesStrings.Localizable.transferUploadSourceChoiceCamera)
                    },
                    icon: { STResourcesAsset.Images.camera.swiftUIImage }
                )
            }
        } label: {
            label
        }
        .photosPicker(isPresented: $isShowingPhotoLibrary, selection: $selectedPhotos, photoLibrary: .shared())
        .onChange(of: selectedPhotos) { _ in
            didSelectFromPhotoLibrary()
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPickerView { image in
                didTakePicture(uiImage: image)
            }
            .ignoresSafeArea()
        }
        .fileImporter(
            isPresented: $isShowingImportFile,
            allowedContentTypes: [.item, .folder],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                completion(urls)
            case .failure(let error):
                Logger.general.error("An error occurred while importing files: \(error)")
            }
        }
    }

    private func didTakePicture(uiImage: UIImage) {
        do {
            let fileName = URL.defaultFileName()
            let url = try URL.tmpCacheDirectory().appendingPathComponent(fileName).appendingPathExtension(for: UTType.png)
            try uiImage.pngData()?.write(to: url)
            completion([url])
        } catch {
            Logger.general.error("An error occurred while saving picture: \(error)")
        }
    }

    private func didSelectFromPhotoLibrary() {
        guard !selectedPhotos.isEmpty else { return }
        Task {
            var photoList = [PhotoLibraryContent]()
            // Save photos
            for photo in selectedPhotos {
                do {
                    guard let newFile = try await photo.loadTransferable(type: PhotoLibraryContent.self) else { continue }
                    photoList.append(newFile)
                } catch {
                    Logger.general.error("An error occurred while saving photo: \(error)")
                }
            }

            let urls = photoList.map {
                $0.url
            }
            completion(urls)
        }
    }
}

#Preview {
    AddFilesMenuView { _ in } label: { EmptyView() }
}
