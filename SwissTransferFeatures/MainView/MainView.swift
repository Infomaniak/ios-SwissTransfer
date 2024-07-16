/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2024 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See them
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import STReceivedView
import STSentView
import STSettingsView
import SwiftUI
import SwissTransferResources

public struct MainView: View {
    public init() {}

    public var body: some View {
        VStack {
            TabView {
                SentView()
                    .tabItem {
                        Label(
                            title: { Text("Envoyé") },
                            icon: { SwissTransferResourcesAsset.Images.arrowUpCircle.swiftUIImage }
                        )
                    }

                ReceivedView()
                    .tabItem {
                        Label(
                            title: { Text("Recu") },
                            icon: { SwissTransferResourcesAsset.Images.arrowDownCircle.swiftUIImage }
                        )
                    }

                SettingsView()
                    .tabItem {
                        Label(
                            title: { Text("Paramètres") },
                            icon: { SwissTransferResourcesAsset.Images.sliderVertical3.swiftUIImage }
                        )
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
