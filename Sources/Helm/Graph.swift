//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation
import SwiftUI
import Collections

/// `NavigationGraph` defines all possible interactions between dynamic views in an app.
public class NavigationGraph<N: Node>: ObservableObject {
    @Published var traits: [Segue<N>: Set<SegueTrait<N>>] = [:]
    @Published var pathFlow: Flow<N> = .init(segues: [])
    private let _navFlow: Flow<N>
    var navFlow: Flow<N> {
        let segues = _navFlow.segues.filter {
            do {
                return try !traits[$0].unwrap().contains(.disabled)
            }
            catch {
                return true
            }
        }
        return Flow(segues: OrderedSet(segues))
    }
    /// Inits the navigation graph using a flow that defines all possible navigation in an app.
    /// When initializing the flow, the `in` node of the first added segue automatically becomes presented (active).
    public init(flow: Flow<N>) {
        self._navFlow = flow
    }
}
