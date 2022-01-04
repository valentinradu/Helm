//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Collections
import Foundation

/// A flow is a unique set of segues that connect two or more nodes.
/// It represents navigation graph connections fully describing them (e.g. when used to init the `NavigationGraph`) or partially (when used to describe various paths in the main flow).
public struct Flow<N: Node>: Hashable {
    let segues: OrderedSet<Segue<N>>

    /// Initializes a flow with multiple segues
    /// - parameter segues: The segues
    init(segues: OrderedSet<Segue<N>>) {
        self.segues = segues
    }

    /// Initializes a flow with a single segue
    /// - parameter segue: The segue
    public init(segue: Segue<N>) {
        segues = [segue]
    }

    /// Initializes a flow using a collection of one-to-one segues
    /// - parameter segue: The segues
    public init(segue: OneToOneSegues<N>) {
        segues = OrderedSet(segue.segues)
    }

    /// Initializes a flow using a collection of one-to-many segues
    /// - parameter segue: The segues
    public init(segue: OneToManySegues<N>) {
        segues = OrderedSet(segue.segues)
    }

    /// Initializes a flow using a collection of many-to-one segues
    /// - parameter segue: The segues
    public init(segue: ManyToOneSegues<N>) {
        segues = OrderedSet(segue.segues)
    }

    /// Adds a new segue to the flow. The initial node has to be already presented.
    /// - parameter segue: The segue
    public func add(segue: Segue<N>) -> Flow<N> {
        .init(segues: segues.union([segue]))
    }

    /// Adds multiple one-to-one segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(segue: OneToOneSegues<N>) -> Flow<N> {
        .init(segues: segues.union(segue.segues))
    }

    /// Adds multiple one-to-many segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(segue: OneToManySegues<N>) -> Flow<N> {
        .init(segues: segues.union(segue.segues))
    }

    /// Adds multiple many-to-one segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(segue: ManyToOneSegues<N>) -> Flow<N> {
        .init(segues: segues.union(segue.segues))
    }

    /// Searches for a segue in the flow
    /// - parameter segue: The segue to search for
    public func has(segue: Segue<N>) -> Bool {
        segues.contains(segue)
    }

    /// Searches for a node in the flow
    /// - parameter node: The node to search for
    public func has(node: N) -> Bool {
        segues
            .flatMap { [$0.in, $0.out] }
            .contains(node)
    }

    /// Returns all the segues that leave a specific node
    /// - parameter for: The node from which the segues leave
    public func egressSegues(for node: N) -> Set<Segue<N>> {
        Set(segues.filter { $0.in == node })
    }

    /// Returns all the segues that arrive a specific node
    /// - parameter for: The node in which the segues arrive
    public func ingressSegues(for node: N) -> Set<Segue<N>> {
        Set(segues.filter { $0.out == node })
    }

    /// Returns another flow without the egress nodes of the specified node.
    /// This function works recursively. If this leads to a circular trimming, the cycle is broke on the initial node.
    public func trim(at: N) -> Flow<N> {
        Flow(segues: [])
    }

    /// Returns true if there are no segues in this flow
    public var isEmpty: Bool {
        segues.isEmpty
    }

    // Substracts the segues of another flow
    public func substract(flow: Flow<N>) -> Flow<N> {
        Flow(segues: segues.subtracting(flow.segues))
    }

    /// Returns all the segues with `in` nodes which are not the `out` nodes of other segues in the flow. In simpler words, segues that can be seen as entry points for the flow.
    public var inlets: Set<Segue<N>> {
        Set(segues)
    }

    /// Returns all the segues with `out` nodes which are not the `in` nodes of any other segues in the flow. In simpler words, segues that can be seen as exit points for the flow.
    public var outlets: Set<Segue<N>> {
        Set(segues)
    }
}
