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

import Foundation
import SwiftUI

enum StateRestorableContainerConstants {
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
}

struct StateRestorableContainer<Data: Codable>: Codable, RawRepresentable, Equatable {
    let data: Data

    init(_ data: Data) {
        self.data = data
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode(Data.self)
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? StateRestorableContainerConstants.decoder.decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

    var rawValue: String {
        guard let data = try? StateRestorableContainerConstants.encoder.encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return result
    }
}

public protocol StateRestorable: ObservableObject {
    associatedtype StateSavable: Codable & Equatable

    func restore(from savedState: StateSavable)
    var savedState: StateSavable { get }
}

public extension View {
    func stateRestorable<State: StateRestorable>(
        key: String,
        _ restorableState: State
    ) -> some View {
        modifier(StateRestorableViewModifier(key: key, restorableState: restorableState))
    }
}

public struct StateRestorableViewModifier<State: StateRestorable>: ViewModifier {
    @SceneStorage private var savedState: StateRestorableContainer<State.StateSavable>

    private let restorableState: State

    public init(key: String, restorableState: State) {
        _savedState = SceneStorage(wrappedValue: StateRestorableContainer(restorableState.savedState), key)
        self.restorableState = restorableState
    }

    public func body(content: Content) -> some View {
        content
            .task(id: restorableState.savedState) {
                savedState = StateRestorableContainer(restorableState.savedState)
            }
            .onAppear {
                restorableState.restore(from: savedState.data)
            }
    }
}
