//
//  File.swift
//
//
//  Created by Valentin Radu on 07/01/2022.
//

import Foundation

public extension DirectedConnectable where N: Fragment {
    /// Constructs a segue from the edge providing the segue rule and auto nav data.
    /// - parameter rule: The rule. Defaults to `.replace`.
    /// - parameter auto: Sets the auto firing behaviour. Defaults to `false`.
    func segue(rule: SeguePresentationRule = .replace, auto: Bool = false) -> Segue<N> {
        Segue(from: from, to: to, rule: rule, auto: auto)
    }
}

public extension Segue {
    /// Gets the edge of a segue.
    var edge: DirectedEdge<N> {
        DirectedEdge(from: from, to: to)
    }
}
