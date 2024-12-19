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
import SwiftUI

extension ProgressViewStyle where Self == CircleDeterminateProgressViewStyle {
    static var circularDeterminate: CircleDeterminateProgressViewStyle {
        return CircleDeterminateProgressViewStyle()
    }
}

struct CircleDeterminateProgressViewStyle: ProgressViewStyle {
    let lineWidth: CGFloat = 2

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(Color.ST.onPrimary, lineWidth: lineWidth)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.ST.primary)
                        .padding(6)
                }
            Circle()
                .trim(from: 0, to: configuration.fractionCompleted ?? 0)
                .stroke(Color.ST.primary, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: configuration.fractionCompleted)
        }
        .frame(width: 20, height: 20)
    }
}

#Preview {
    VStack {
        ProgressView(value: 0)
        ProgressView(value: 0.25)
        ProgressView(value: 0.5)
        ProgressView(value: 1)
    }
    .progressViewStyle(.circularDeterminate)
    .background(Color.gray)
}
