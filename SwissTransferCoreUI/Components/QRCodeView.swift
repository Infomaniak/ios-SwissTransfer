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

import QRCode
import STResources
import SwiftUI

public struct QRCodeView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var generatedDocument: QRCode.Document?
    @State private var isShowingError = false

    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        VStack {
            if let generatedDocument {
                QRCodeDocumentUIView(document: generatedDocument)
            } else if isShowingError {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.ST.title)
                    Text(STResourcesStrings.Localizable.errorGeneratingQRCode)
                        .font(.ST.headline)
                }
                .foregroundStyle(Color.ST.error)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            computeQRCode()
        }
        .onChange(of: colorScheme) { newColorScheme in
            computeQRCode(newColorScheme)
        }
    }

    private func computeQRCode(_ newColorScheme: ColorScheme? = nil) {
        do {
            let colorScheme = newColorScheme ?? colorScheme
            var documentBuilder = try QRCode.build
                .url(url)
                .errorCorrection(.high)
                .foregroundColor(getQRCodeColor(colorScheme))
                .backgroundColor(getBackgroundColor(colorScheme))

            if let logo = STResourcesAsset.Images.logoK.image.cgImage {
                let template = QRCode.LogoTemplate(
                    image: logo,
                    path: CGPath(rect: CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.3), transform: nil),
                    inset: 2
                )
                documentBuilder = documentBuilder.logo(template)
            }

            generatedDocument = documentBuilder.document
        } catch {
            isShowingError = true
        }
    }

    private func getQRCodeColor(_ newColorScheme: ColorScheme) -> CGColor {
        let qrCodeColor = newColorScheme == .light ? STResourcesAsset.Colors.greenDark : STResourcesAsset.Colors.white
        return qrCodeColor.color.cgColor
    }

    private func getBackgroundColor(_ newColorScheme: ColorScheme) -> CGColor {
        let backgroundColor = newColorScheme == .light ? STResourcesAsset.Colors.white : STResourcesAsset.Colors.dark0
        return backgroundColor.color.cgColor
    }
}

#Preview {
    QRCodeView(url: URL(string: "https://www.infomaniak.com")!)
}
