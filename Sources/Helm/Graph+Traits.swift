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
        .init(segues: [])
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The one-to-one segues to edit
    func edit(segue: OneToOneSegues<N>) -> SegueTraitOperation<N> {
        .init(segues: [])
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The one-to-many segues to edit
    func edit(segue: OneToManySegues<N>) -> SegueTraitOperation<N> {
        .init(segues: [])
    }

    /// Returns an operation used to edit the traits of multiple segues.
    /// Used mainly when defining the segues using the connector operator.
    /// - parameter segue: The many-to-one segues to edit
    func edit(segue: ManyToOneSegues<N>) -> SegueTraitOperation<N> {
        .init(segues: [])
    }
}
