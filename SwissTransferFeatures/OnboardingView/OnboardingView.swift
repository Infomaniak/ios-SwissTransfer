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
import InfomaniakCoreUIResources
import InfomaniakDI
import InfomaniakOnboarding
import STResources
import SwiftUI
import SwissTransferCore
import SwissTransferCoreUI

extension Slide {
    static var onboardingSlides: [Slide] {
        return [
            Slide(
                backgroundImage: STResourcesAsset.Images.onboardingBlurRight.image,
                backgroundImageTintColor: nil,
                content: .animation(
                    IKLottieConfiguration(
                        id: 1,
                        filename: "storage-cardboard-box",
                        bundle: STResourcesResources.bundle
                    )
                ),
                bottomView: OnboardingTextView(text: .storage)
            ),
            Slide(
                backgroundImage: STResourcesAsset.Images.onboardingBlurLeft.image,
                backgroundImageTintColor: nil,
                content: .animation(
                    IKLottieConfiguration(
                        id: 2,
                        filename: "cards-transfer-type",
                        bundle: STResourcesResources.bundle
                    )
                ),
                bottomView: OnboardingTextView(text: .expiration)
            ),
            Slide(
                backgroundImage: STResourcesAsset.Images.onboardingBlurRight.image,
                backgroundImageTintColor: nil,
                content: .animation(
                    IKLottieConfiguration(
                        id: 3,
                        filename: "padlocks",
                        bundle: STResourcesResources.bundle
                    )
                ),
                bottomView: OnboardingTextView(text: .password)
            ),
            Slide(
                backgroundImage: STResourcesAsset.Images.onboardingBlurLeft.image,
                backgroundImageTintColor: nil,
                content: .animation(
                    IKLottieConfiguration(
                        id: 4,
                        filename: "padlocks",
                        bundle: STResourcesResources.bundle
                    )
                ),
                bottomView: OnboardingTextView(text: .sendFiles)
            )
        ]
    }
}

public struct OnboardingView: View {
    @LazyInjectService private var accountManager: AccountManager

    @EnvironmentObject private var rootViewState: RootViewState
    @EnvironmentObject private var universalLinksState: UniversalLinksState

    @State private var selectedSlideIndex = 0

    public init() {}

    public var body: some View {
        CarouselView(slides: Slide.onboardingSlides, selectedSlide: $selectedSlideIndex) { _ in
            OnboardingBottomButtonsView(selection: $selectedSlideIndex, slideCount: Slide.onboardingSlides.count)
        }
        .appBackground()
        .ignoresSafeArea()
        .onChange(of: universalLinksState.linkedTransfer) { linkedTransfer in
            guard let linkedTransfer else { return }

            Task {
                if let currentManager = await accountManager.getCurrentManager() {
                    let mainViewState = MainViewState(transferManager: currentManager)

                    mainViewState.handleDeepLink(linkedTransfer)
                    universalLinksState.linkedTransfer = nil
                    withAnimation {
                        rootViewState.state = .mainView(mainViewState)
                    }
                } else {
                    universalLinksState.linkedTransfer = nil
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .ikButtonTheme(.swissTransfer)
        .tint(.ST.primary)
}
