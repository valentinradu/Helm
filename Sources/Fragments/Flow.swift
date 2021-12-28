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
    var segues: Set<Segue<N>>

    /// Initializes a empty flow without any segues.
    public init() {
        segues = []
    }

    /// Initializes a flow by linking together a set of nodes one after the other
    public init(nodes: N...) {
        self.init(nodes: nodes)
    }

    /// Initializes a flow by linking together a set of nodes one after the other
    public init(nodes: [N]) {
        segues = []
    }

    /// Convenience method for initializing a flow from an array of nodes
    public static func from(nodes: N...) -> Self {
        .init(nodes: nodes)
    }

    /// Connects one node to another using a segue
    /// - parameter segue: The segue
    public mutating func add(segue: Segue<N>) {}

    /// Used by the connector operator to add one or multiple segues to the graph, chained one after the other.
    public mutating func add(segue: OneToOneSegues<N>) {}

    /// Used by the connector operator multiple segues that diverge from one node
    public mutating func add(segue: OneToManySegues<N>) {}

    /// Used by the connector operator multiple segues that converge to one node
    public mutating func add(segue: ManyToOneSegues<N>) {}
}
