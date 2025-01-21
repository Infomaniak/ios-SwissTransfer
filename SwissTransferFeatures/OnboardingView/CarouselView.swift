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

import InfomaniakOnboarding
import Lottie
import STResources
import SwiftUI

struct CarouselView<BottomView: View>: UIViewControllerRepresentable {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selectedSlide: Int

    let slides: [Slide]

    @ViewBuilder var bottomView: (Int) -> BottomView

    init(slides: [Slide], selectedSlide: Binding<Int>, @ViewBuilder bottomView: @escaping (Int) -> BottomView) {
        self.slides = slides
        _selectedSlide = selectedSlide
        self.bottomView = bottomView
    }

    func makeUIViewController(context: Context) -> OnboardingViewController {
        let configuration = OnboardingConfiguration(
            headerImage: nil,
            slides: slides,
            pageIndicatorColor: STResourcesAsset.Colors.greenMain.color,
            isScrollEnabled: true,
            dismissHandler: nil,
            isPageIndicatorHidden: false
        )

        let controller = OnboardingViewController(configuration: configuration)
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: OnboardingViewController, context: Context) {
        if uiViewController.pageIndicator.currentPage != selectedSlide {
            uiViewController.setSelectedSlide(index: selectedSlide)
        }

        if colorScheme != context.coordinator.currentColorScheme, let currentSlideViewCell = uiViewController.currentSlideViewCell {
            context.coordinator.currentColorScheme = context.environment.colorScheme
            print(colorScheme, context.coordinator.currentColorScheme, context.environment.colorScheme)
            context.coordinator.selectCorrectAnimation(for: currentSlideViewCell, at: selectedSlide)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, colorScheme: colorScheme)
    }

    class Coordinator: OnboardingViewControllerDelegate {
        let parent: CarouselView<BottomView>

        var currentColorScheme: ColorScheme

        init(parent: CarouselView<BottomView>, colorScheme: ColorScheme) {
            self.parent = parent
            currentColorScheme = colorScheme
        }

        func bottomViewForIndex(_ index: Int) -> (any View)? {
            return parent.bottomView(index)
        }

        func shouldAnimateBottomViewForIndex(_ index: Int) -> Bool {
            return index == parent.slides.count - 1
        }

        func willDisplaySlideViewCell(_ slideViewCell: SlideCollectionViewCell, at index: Int) {
            selectCorrectAnimation(for: slideViewCell, at: index)
        }

        func currentIndexChanged(newIndex: Int) {
            Task { @MainActor in
                parent.$selectedSlide.wrappedValue = newIndex
            }
        }

        func selectCorrectAnimation(for slideViewCell: SlideCollectionViewCell, at index: Int) {
            guard case .animation(let configuration) = parent.slides[index].content else { return }

            let suffix = currentColorScheme == .dark ? "dark" : "light"
            let animation = LottieAnimation.named("\(configuration.filename)-\(suffix)", bundle: configuration.bundle)
            slideViewCell.illustrationAnimationView.animation = animation
            slideViewCell.illustrationAnimationView.play()
        }
    }
}
