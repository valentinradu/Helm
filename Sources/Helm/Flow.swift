//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

/// A flow is a unique set of segues that connect two or more nodes.
/// It represents navigation graph connections fully describing them (e.g. when used to init the `NavigationGraph`) or partially (when used to describe various paths in the main flow).
public struct Flow<N: Node>: Hashable {
    let segues: [Segue<N>]

    /// Initializes a flow with multiple segues
    /// - parameter segues: The segues
    init(segues: [Segue<N>]) {
        self.segues = segues
    }

    /// Initializes a flow with a single segue
    /// - parameter segue: The segue
    public init(segue: Segue<N>) {
        segues = []
    }

    /// Initializes a flow using a collection of one-to-one segues
    /// - parameter segue: The segues
    public init(segue: OneToOneSegues<N>) {
        segues = []
    }

    /// Initializes a flow using a collection of one-to-many segues
    /// - parameter segue: The segues
    public init(segue: OneToManySegues<N>) {
        segues = []
    }

    /// Initializes a flow using a collection of many-to-one segues
    /// - parameter segue: The segues
    public init(segue: ManyToOneSegues<N>) {
        segues = []
    }

    /// Adds a new segue to the flow. The initial node has to be already presented.
    /// - parameter segue: The segue
    public func add(segue: Segue<N>) -> Flow<N> {
        .init(segues: [])
    }

    /// Adds multiple one-to-one segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(segue: OneToOneSegues<N>) -> Flow<N> {
        .init(segues: [])
    }

    /// Adds multiple one-to-many segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(segue: OneToManySegues<N>) -> Flow<N> {
        .init(segues: [])
    }

    /// Adds multiple many-to-one segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(segue: ManyToOneSegues<N>) -> Flow<N> {
        .init(segues: [])
    }
}
