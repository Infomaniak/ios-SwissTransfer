/*
 Infomaniak SwissTransfer - iOS App
 Copyright (C) 2025 Infomaniak Network SA

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

import InfomaniakCoreCommonUI
import InfomaniakDI
import InfomaniakOnboarding
import SwiftUI

public struct SingleOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var loginHandler = LoginHandler()

    private let slides = [Slide.onboardingSlides.last!]

    public init() {}

    public var body: some View {
        CarouselView(slides: slides, selectedSlide: .constant(0), dismissHandler: dismiss.callAsFunction) { _ in
            OnboardingBottomButtonsView(
                loginHandler: loginHandler,
                isPresentingInterAppLogin: true,
                selection: .constant(0),
                slideCount: slides.count
            )
        }
        .appBackground()
        .ignoresSafeArea()
    }
}

#Preview {
    SingleOnboardingView()
}
