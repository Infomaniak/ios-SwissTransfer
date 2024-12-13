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

public struct AddFilesMenu<Content: View>: View {
    @State private var isShowingImportFile = false
    @State private var isShowingCamera = false
    @State private var isShowingPhotoLibrary = false
    @State private var selectedPhotos: [PhotosPickerItem] = []

    @Binding var selection: [ImportedItem]

    private let label: Content

    public init(selection: Binding<[ImportedItem]>, @ViewBuilder label: () -> Content) {
        _selection = selection
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
            CameraPickerView(onImagePicked: didTakePicture)
                .ignoresSafeArea()
        }
        .fileImporter(
            isPresented: $isShowingImportFile,
            allowedContentTypes: [.item, .folder],
            allowsMultipleSelection: true,
            onCompletion: didSelectFromFileSystem
        )
    }

    private func didTakePicture(uiImage: UIImage) {
        selection = [ImportedItem(item: uiImage)]
    }

    private func didSelectFromPhotoLibrary() {
        guard !selectedPhotos.isEmpty else { return }
        selection = selectedPhotos.map { ImportedItem(item: $0) }
        selectedPhotos = []
    }

    private func didSelectFromFileSystem(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selection = urls.map { ImportedItem(item: $0) }
        case .failure(let error):
            Logger.general.error("An error occurred while importing files: \(error)")
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selection = [ImportedItem]()
    AddFilesMenu(selection: $selection) {}
}
