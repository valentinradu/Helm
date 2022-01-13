//
//  File.swift
//
//
//  Created by Valentin Radu on 07/01/2022.
//

import Foundation

public extension Segue {
    /// Gets the edge of a segue.
    var edge: DirectedEdge<N> {
        DirectedEdge(from: from, to: to)
    }
}
