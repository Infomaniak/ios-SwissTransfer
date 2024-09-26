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


struct NewTransferSettingsView: View {
    @State private var duration = 30
    let durations: [Int] = [30, 15, 7, 1]

    @State private var limit = 250
    let limits: [Int] = [250, 100, 20, 1]

    @State private var showPasswordSetting = false

    @State private var language: TransferLanguage = .fr

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paramètres avancées")

            VStack(alignment: .leading, spacing: 32) {
                Menu {
                    ForEach(durations, id: \.self) { value in
                        Button("\(value) jours") {
                            duration = value
                        }
                    }
                } label: {
                    HStack {
                        Label {
                            Text("Durée de validité")
                                .font(.ST.calloutMedium)
                                .foregroundStyle(Color.ST.primary)
                        } icon: {
                            STResourcesAsset.Images.clock.swiftUIImage
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .labelStyle(.horizontal)

                        Spacer()

                        Text("\(duration) jours")
                            .font(.ST.callout)
                            .foregroundStyle(Color.ST.textSecondary)
                    }
                }

                Menu {
                    ForEach(limits, id: \.self) { value in
                        Button("\(value)") {
                            limit = value
                        }
                    }
                } label: {
                    HStack {
                        Label {
                            Text("Limite de téléchargements")
                                .font(.ST.calloutMedium)
                                .foregroundStyle(Color.ST.primary)
                        } icon: {
                            STResourcesAsset.Images.fileDownload.swiftUIImage
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .labelStyle(.horizontal)

                        Spacer()

                        Text("\(limit)")
                            .font(.ST.callout)
                            .foregroundStyle(Color.ST.textSecondary)
                    }
                }

                Button {
                    showPasswordSetting = true
                } label: {
                    HStack {
                        Label {
                            Text("Mot de passe")
                                .font(.ST.calloutMedium)
                                .foregroundStyle(Color.ST.primary)
                        } icon: {
                            STResourcesAsset.Images.password.swiftUIImage
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .labelStyle(.horizontal)

                        Spacer()

                        Text("Aucun")
                            .font(.ST.callout)
                            .foregroundStyle(Color.ST.textSecondary)
                    }
                }

                Menu {
                    ForEach(TransferLanguage.allCases, id: \.self) { value in
                        Button {
                            language = value
                        } label: {
                            Label {
                                Text(value.title)
                            } icon: {
                                value.flag
                            }
                        }
                    }
                } label: {
                    HStack {
                        Label {
                            Text("Langue du mail")
                                .font(.ST.calloutMedium)
                                .foregroundStyle(Color.ST.primary)
                        } icon: {
                            STResourcesAsset.Images.language.swiftUIImage
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .labelStyle(.horizontal)

                        Spacer()

                        Text(language.title)
                            .font(.ST.callout)
                            .foregroundStyle(Color.ST.textSecondary)
                    }
                }
            }
            .padding(value: .large)
            .frame(maxWidth: .infinity)
            .background(
                Color.ST.cardBackground
                    .clipShape(.rect(cornerRadius: 16))
            )
            .sheet(isPresented: $showPasswordSetting) {
                PasswordSettingView()
            }
        }
    }
}

#Preview {
    NewTransferSettingsView()
}
