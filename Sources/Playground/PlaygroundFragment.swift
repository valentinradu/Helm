//
//  File.swift
//
//
//  Created by Valentin Radu on 12/12/2021.
//

import Foundation
import Helm

typealias PlaygroundSegue = Segue<PlaygroundFragment>
typealias PlaygroundGraph = Set<PlaygroundSegue>
typealias PlaygroundEdge = DirectedEdge<PlaygroundFragment>

extension String: Identifiable {
    public var id: String {
        self
    }
}

enum PlaygroundFragment: Fragment {
    case a
    case b
    case c
    case d
}
