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
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

extension VerticalAlignment {
    enum SplashScreenIconAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[VerticalAlignment.center]
        }
    }

    static let splashScreenIconAlignment = VerticalAlignment(SplashScreenIconAlignment.self)
}

struct PreloadingView: View {
    @LazyInjectService private var accountManager: AccountManager

    @EnvironmentObject private var rootViewState: RootViewState

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .splashScreenIconAlignment)) {
            STRootViewAsset.splashscreenBackground.swiftUIImage
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: IKPadding.large) {
                STRootViewAsset.splashscreenSwisstransfer.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 156)
                    .alignmentGuide(.splashScreenIconAlignment) { d in d[VerticalAlignment.center] }

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(STResourcesAsset.Colors.white.swiftUIColor)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            STRootViewAsset.splashscreenInfomaniak.swiftUIImage
                .padding(.bottom, value: .medium)
        }
        .task {
            if let currentManager = await accountManager.getCurrentManager() {
                rootViewState.state = .mainView(MainViewState(transferManager: currentManager))
            } else {
                rootViewState.state = .onboarding
            }
        }
    }
}

#Preview {
    PreloadingView()
        .environmentObject(RootViewState())
}
