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
    func edit(segue: Segue<N>) throws -> SegueTraitOperation<N> {
        try _edit(segue: [segue])
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The one-to-one segues to edit
    func edit(segue: OneToOneSegues<N>) throws -> SegueTraitOperation<N> {
        try _edit(segue: Set(segue.segues))
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The one-to-many segues to edit
    func edit(segue: OneToManySegues<N>) throws -> SegueTraitOperation<N> {
        try _edit(segue: Set(segue.segues))
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The many-to-one segues to edit
    func edit(segue: ManyToOneSegues<N>) throws -> SegueTraitOperation<N> {
        try _edit(segue: Set(segue.segues))
    }

    private func _edit(segue: Set<Segue<N>>) throws -> SegueTraitOperation<N> {
        let segues = segue.filter { !navFlow.has(segue: $0) }
        guard segues.count == 0 else {
            throw HelmError.missingSegues(value: segues)
        }
        return .init(graph: self, segues: segue)
    }
}
