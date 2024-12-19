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

import SwiftUI

struct CircleProgressView: View {
    let progress: Double
    let lineWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.ST.onPrimary, lineWidth: lineWidth)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.ST.primary)
                        .padding(value: .extraSmall)
                }
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.ST.primary, lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
        .frame(width: 20, height: 20)
    }
}

#Preview {
    VStack {
        CircleProgressView(progress: 0)
        CircleProgressView(progress: 0.25)
        CircleProgressView(progress: 0.5)
        CircleProgressView(progress: 1)
    }
    .background(Color.gray)
}
