//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation
import SwiftUI

/// `NavigationGraph` defines all possible interactions between dynamic views in an app.
public class NavigationGraph<N: Node>: ObservableObject {
    @Published var traits: [Segue<N>: Set<SegueTrait<N>>] = [:]
    @Published var activeFlow: Flow<N> = .init(segues: [])
    /// Inits the navigation graph using a flow that defines all possible navigation in an app.
    /// When initializing the flow, the `in` node of the first added segue automatically becomes presented (active).
    public init(flow: Flow<N>) {}
}
