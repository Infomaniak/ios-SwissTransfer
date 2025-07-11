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

import DesignSystem
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STResources
import SwiftUI
import SwissTransferCoreUI

struct PasswordPanelView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingPassword = false

    let password: String
    let matomoCategory: MatomoUtils.EventCategory

    private var passwordValue: String {
        isShowingPassword ? password : String(repeating: "*", count: password.count)
    }

    var body: some View {
        VStack(spacing: IKPadding.large) {
            Text(STResourcesStrings.Localizable.sharePasswordTitle)
                .font(.ST.headline)
                .foregroundStyle(Color.ST.textPrimary)

            Text(STResourcesStrings.Localizable.sharePasswordDescription)
                .font(.ST.body)
                .foregroundStyle(Color.ST.textSecondary)
                .multilineTextAlignment(.center)

            HStack {
                Text(passwordValue)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    withAnimation {
                        @InjectService var matomo: MatomoUtils
                        matomo.track(eventWithCategory: matomoCategory, name: "showPassword")
                        isShowingPassword.toggle()
                    }
                } label: {
                    isShowingPassword ? STResourcesAsset.Images.eyeSlash.swiftUIImage : STResourcesAsset.Images.eye.swiftUIImage
                }
            }
            .foregroundStyle(Color.ST.textSecondary)
            .padding(value: .small)
            .overlay(Color.ST.textFieldBorder, in: .rect(cornerRadius: IKRadius.small).stroke())
            .padding(.bottom, 30)

            BottomButtonsView {
                CopyToClipboardButton(
                    text: STResourcesStrings.Localizable.sharePasswordButton,
                    item: password,
                    labelStyle: .ikLabel,
                    matomoCategory: matomoCategory,
                    matomoName: "copyPassword"
                )
                .buttonStyle(.ikBorderedProminent)

                Button {
                    dismiss()
                } label: {
                    Text(STResourcesStrings.Localizable.contentDescriptionButtonClose)
                        .font(.ST.headline)
                }
                .buttonStyle(.ikBorderless)
            }
        }
        .padding(.horizontal, value: .medium)
        .padding(.top, value: .medium)
    }
}

#Preview {
    PasswordPanelView(password: "Password", matomoCategory: .sentTransfer)
}
