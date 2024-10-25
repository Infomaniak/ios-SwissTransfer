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

struct QRCodeView: View {
    @Environment(\.colorScheme) private var colorScheme

    let url: URL

    @State private var document: QRCode.Document?
    @State private var isShowingError = false

    var body: some View {
        VStack {
            if let document {
                QRCodeDocumentUIView(document: document)
            } else if isShowingError {
                Text("Error")
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

    private func computeQRCode(_ colorScheme: ColorScheme? = nil) {
        do {
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

            document = documentBuilder.document
        } catch {
            isShowingError = true
        }
    }

    private func getQRCodeColor(_ newColorScheme: ColorScheme?) -> CGColor {
        let preferredColorScheme = newColorScheme ?? colorScheme
        let color = preferredColorScheme == .light ? STResourcesAsset.Colors.greenDark : STResourcesAsset.Colors.white

        return color.color.cgColor
    }

    private func getBackgroundColor(_ newColorScheme: ColorScheme?) -> CGColor {
        let preferredColorScheme = newColorScheme ?? colorScheme
        let color = preferredColorScheme == .light ? STResourcesAsset.Colors.white : STResourcesAsset.Colors.dark0

        return color.color.cgColor
    }
}

#Preview {
    QRCodeView(url: URL(string: "https://www.infomaniak.com")!)
}
