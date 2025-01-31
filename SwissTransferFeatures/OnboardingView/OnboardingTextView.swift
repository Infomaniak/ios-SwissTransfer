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
import InfomaniakCoreSwiftUI
import STResources
import SwiftUI

enum OnboardingText {
    case storage
    case expiration
    case password

    var title: String {
        switch self {
        case .storage:
            STResourcesStrings.Localizable.onboardingStorageTitle
        case .expiration:
            STResourcesStrings.Localizable.onboardingExpirationTitle
        case .password:
            STResourcesStrings.Localizable.onboardingPasswordTitle
        }
    }

    var subtitle: AttributedString {
        var result = AttributedString(template(argument))
        result.font = .ST.specificTitleMedium

        if let argumentRange = result.range(of: argument) {
            result[argumentRange].font = .ST.specificTitleMedium
        }

        return result
    }

    private var argument: String {
        switch self {
        case .storage:
            STResourcesStrings.Localizable.onboardingStorageSubtitleArgument
        case .expiration:
            STResourcesStrings.Localizable.onboardingExpirationSubtitleArgument
        case .password:
            STResourcesStrings.Localizable.onboardingPasswordSubtitleArgument
        }
    }

    private var template: (Any) -> String {
        switch self {
        case .storage:
            STResourcesStrings.Localizable.onboardingStorageSubtitleTemplate
        case .expiration:
            STResourcesStrings.Localizable.onboardingExpirationSubtitleTemplate
        case .password:
            STResourcesStrings.Localizable.onboardingPasswordSubtitleTemplate
        }
    }
}

struct OnboardingTextView: View {
    let text: OnboardingText

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            Text(text.title)
                .font(.ST.specificTitleLight)

            Text(text.subtitle)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    OnboardingTextView(text: .storage)
    OnboardingTextView(text: .expiration)
    OnboardingTextView(text: .password)
}
