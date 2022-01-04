//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

public extension NavigationGraph {
    /// Returns an operation used to edit the traits of a segue
    /// - parameter segue: The segue to edit
    func edit(segue: Segue<N>) -> SegueTraitOperation<N> {
        edit(segue: [segue])
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The one-to-one segues to edit
    func edit(segue: OneToOneSegues<N>) -> SegueTraitOperation<N> {
        edit(segue: Set(segue.segues))
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The one-to-many segues to edit
    func edit(segue: OneToManySegues<N>) -> SegueTraitOperation<N> {
        edit(segue: Set(segue.segues))
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The many-to-one segues to edit
    func edit(segue: ManyToOneSegues<N>) -> SegueTraitOperation<N> {
        edit(segue: Set(segue.segues))
    }

    private func edit(segue: Set<Segue<N>>) -> SegueTraitOperation<N> {
        let unreachableSegues = segue.filter { !flow.has(segue: $0) }
        guard unreachableSegues.count == 0 else {
            reportError("Cannot edit traits for the following unreachable segues: \(unreachableSegues). Check the navigation graph and make sure these segues are defined.")
            return .init(graph: self, segues: [])
        }
        return .init(graph: self, segues: segue)
    }
}
