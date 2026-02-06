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

public struct PreloadingView: View {
    @LazyInjectService private var accountManager: AccountManagerable

    @EnvironmentObject private var rootViewState: RootViewState

    private let backgroundImage = Image("splashscreen-background", bundle: .main)
    private let logoImage = Image("splashscreen-swisstransfer", bundle: .main)
    private let infomaniakLogoImage = Image("splashscreen-infomaniak", bundle: .main)

    private let skipOnboarding: Bool

    public init(skipOnboarding: Bool = false) {
        self.skipOnboarding = skipOnboarding
    }

    public var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .splashScreenIconAlignment)) {
            backgroundImage
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            VStack(spacing: IKPadding.large) {
                logoImage
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
            infomaniakLogoImage
                .padding(.bottom, value: .medium)
        }
        .task {
            if let currentManager = await accountManager.getCurrentManager() {
                rootViewState.state = .mainView(MainViewState(transferManager: currentManager))
            } else if skipOnboarding {
                await accountManager.createAndSetCurrentAccount()
                if let currentManager = await accountManager.getCurrentManager() {
                    rootViewState.state = .mainView(MainViewState(transferManager: currentManager))
                } else {
                    // As a last resort we still go to onboarding
                    rootViewState.state = .onboarding
                }
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
