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

import InfomaniakCoreSwiftUI
import STResources
import SwiftUI

// MARK: - UIColor

public extension UIColor {
    enum ST {
        // MARK: Recipient Labels

        public static let recipientLabelBackground = UIColor(
            light: STResourcesAsset.Colors.greenSecondary,
            dark: STResourcesAsset.Colors.greenDark
        )

        public static let onRecipientLabelBackground = UIColor(
            light: STResourcesAsset.Colors.greenDark,
            dark: STResourcesAsset.Colors.greenMain
        )
    }
}

extension UIColor {
    convenience init(light: STResourcesColors, dark: STResourcesColors) {
        self.init { $0.userInterfaceStyle == .dark ? dark.color : light.color }
    }
}

// MARK: - Color

public extension Color {
    /// List of colors used by the SwissTransfer app.
    enum ST {
        // MARK: Generics

        /// light: greyMouse / dark: dark2
        private static let border = Color(
            light: STResourcesAsset.Colors.greyMouse,
            dark: STResourcesAsset.Colors.dark2
        )

        // MARK: Texts

        /// light: greyOrca / dark: greyRabbit
        public static let textPrimary = Color(
            light: STResourcesAsset.Colors.greyOrca,
            dark: STResourcesAsset.Colors.greyRabbit
        )
        /// light: greyElephant / dark: greyShark
        public static let textSecondary = Color(
            light: STResourcesAsset.Colors.greyElephant,
            dark: STResourcesAsset.Colors.greyShark
        )

        // MARK: General

        /// greenMain
        public static let primary = STResourcesAsset.Colors.greenMain.swiftUIColor
        /// light: greenText / dark: dark0
        public static let onPrimary = Color(
            light: STResourcesAsset.Colors.greenText,
            dark: STResourcesAsset.Colors.dark0
        )

        /// greenDark
        public static let secondary = STResourcesAsset.Colors.greenDark.swiftUIColor
        /// light: greenContrast / dark: greenMain
        public static let onSecondary = Color(
            light: STResourcesAsset.Colors.greenContrast,
            dark: STResourcesAsset.Colors.greenMain
        )

        /// light: white / dark: dark0
        public static let background = Color(
            light: STResourcesAsset.Colors.white,
            dark: STResourcesAsset.Colors.dark0
        )
        /// light: greyMouse / dark: dark2
        public static let divider = Color(
            light: STResourcesAsset.Colors.greyMouse,
            dark: STResourcesAsset.Colors.dark2
        )
        /// red
        public static let error = STResourcesAsset.Colors.red.swiftUIColor
        /// orange
        public static let warning = STResourcesAsset.Colors.orange.swiftUIColor
        /// light: greenSecondary / dark: greenDark
        public static let highlighted = Color(
            light: STResourcesAsset.Colors.greenSecondary,
            dark: STResourcesAsset.Colors.greenDark
        )

        // MARK: TextFields

        /// light: greyMouse / dark: dark2
        public static let textFieldBorder = border
        /// light: greyMouse / dark: dark2
        public static let focusedTextFieldBorder = primary

        // MARK: Buttons

        /// light: greyRabbit / dark: dark1
        public static let tertiaryButton = Color(
            light: STResourcesAsset.Colors.greyRabbit,
            dark: STResourcesAsset.Colors.dark1
        )

        /// light: greyShark / dark: greyElephant
        public static let disabledState = Color(
            light: STResourcesAsset.Colors.greyShark,
            dark: STResourcesAsset.Colors.greyElephant
        )
        public static let onDisabledState = Color(
            light: STResourcesAsset.Colors.white,
            dark: STResourcesAsset.Colors.dark0
        )

        // MARK: Recipient Labels

        /// see `UIColor.ST.recipientLabelBackground`
        public static let recipientLabelBackground = Color(uiColor: .ST.recipientLabelBackground)
        /// see `UIColor.ST.onRecipientLabelBackground`
        public static let onRecipientLabelBackground = Color(uiColor: .ST.onRecipientLabelBackground)

        // MARK: Cards

        /// light: greyPolarBear / dark: dark1
        public static let cardBackground = Color(
            light: STResourcesAsset.Colors.greyPolarBear,
            dark: STResourcesAsset.Colors.dark1
        )
        /// light: greyMouse / dark: dark2
        public static let cardBorder = border

        // MARK: File Type

        public static let folder = FileType.unknown.color
    }
}

extension Color {
    init(light: STResourcesColors, dark: STResourcesColors) {
        self.init(uiColor: UIColor(light: light, dark: dark))
    }
}
