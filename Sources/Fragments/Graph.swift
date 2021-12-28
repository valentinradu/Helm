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
    /// Inits the navigation graph using a flow that defines all possible navigation in an app
    public init(flow: Flow<N>) {}
}
