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

import STResources
import SwiftUI
import QRCode

extension UIColor {
    static var qrCode: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return STResourcesAsset.Colors.greenDark.color
            case .dark:
                return STResourcesAsset.Colors.white.color
            @unknown default:
                fatalError()
            }
        }
    }
}

struct QRCodeView: View {
    @Environment(\.colorScheme) private var colorScheme

    let url: URL

    private var qrCode: CGImage? {
        try? QRCode.build
            .url(url)
            .foregroundColor(STResourcesAsset.Colors.greenDark.color.cgColor)
            .logo(STResourcesAsset.Images.logoK.image.cgImage!, position: .squareCenter(inset: 8))
            .logo(image: STResourcesAsset.Images.logoK.image.cgImage!, unitRect: CGRect(x: 0.375, y: 0.375, width: 0.25, height: 0.25), inset: 8)
            .generate
            .image(dimension: 320)
    }

    @State private var document: QRCode.Document?
    @State private var isShowingError = false

    var body: some View {
        VStack {
            if let document {
                QRCodeDocumentUIView(document: document)
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
            let generatedDocument = try QRCode.Document(utf8String: url.absoluteString)
            generatedDocument.design.foregroundColor(getQRCodeColor(colorScheme))
            generatedDocument.design.backgroundColor(nil)

            if let logo = STResourcesAsset.Images.logoK.image.cgImage {
                generatedDocument.logoTemplate = .SquareCenter(image: logo)
            }

            document = generatedDocument
        } catch {
            isShowingError = true
        }
    }

    private func getQRCodeColor(_ newColorScheme: ColorScheme?) -> CGColor {
        let preferredColorScheme = newColorScheme ?? colorScheme
        let color = preferredColorScheme == .light ? STResourcesAsset.Colors.greenDark : STResourcesAsset.Colors.white

        return color.color.cgColor
    }
}

#Preview {
    QRCodeView(url: URL(string: "https://www.infomaniak.com")!)
}
