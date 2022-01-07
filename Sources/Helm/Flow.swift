//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Collections
import Foundation

/// A flow is a unique set of segues that connect two or more nodes.
public struct Flow<N: Node>: Hashable {
    private let segues: OrderedSet<Segue<N>>

    private init(rels: OrderedSet<SegueRel<N>>, grant: SegueGrant, auto: Bool) {
        self.init(segues: OrderedSet(rels.map { $0.segue(grant: grant, auto: auto) }))
    }

    private func add(rels: OrderedSet<SegueRel<N>>, grant: SegueGrant, auto: Bool) -> Flow<N> {
        let newSegues = rels.map {
            $0.segue(grant: grant, auto: auto)
        }
        return Flow(segues: segues.union(newSegues))
    }

    /// Initializes a flow with a single segue
    /// - parameter segue: The segue
    public init(segue: Segue<N>) {
        self.init(segues: [segue])
    }

    /// Initializes a flow with multiple segues
    /// - parameter segues: The segues
    public init(segues: OrderedSet<Segue<N>>) {
        var dict: [SegueRel<N>: Segue<N>] = [:]
        for segue in segues {
            dict[segue.rel] = segue
        }
        self.segues = OrderedSet(segues.compactMap { dict[$0.rel] })
    }

    /// Initializes a flow using a collection of one-to-one segues
    /// - parameter segue: The segues
    /// - parameter grant: The grant type for all resulting segues. Defaults to `.pass`.
    /// - parameter auto: The auto firing behaviour for all resulting segues. Defaults to `false`.
    public init(
        segue: OneToOneSegues<N>,
        grant: SegueGrant = .pass,
        auto: Bool = false
    ) {
        self.init(rels: segue.rels, grant: grant, auto: auto)
    }

    /// Initializes a flow using a collection of one-to-many segues
    /// - parameter segue: The segues
    /// - parameter grant: The grant type for all resulting segues. Defaults to `.pass`.
    /// - parameter auto: The auto firing behaviour for all resulting segues. Defaults to `false`.
    public init(
        segue: OneToManySegues<N>,
        grant: SegueGrant = .pass,
        auto: Bool = false
    ) {
        self.init(rels: OrderedSet(segue.rels), grant: grant, auto: auto)
    }

    /// Initializes a flow using a collection of many-to-one segues
    /// - parameter segue: The segues
    /// - parameter grant: The grant type for all resulting segues. Defaults to `.pass`.
    /// - parameter auto: The auto firing behaviour for all resulting segues. Defaults to `false`.
    public init(
        segue: ManyToOneSegues<N>,
        grant: SegueGrant = .pass,
        auto: Bool = false
    ) {
        self.init(rels: OrderedSet(segue.rels), grant: grant, auto: auto)
    }

    /// Adds a new segue to the flow. The initial node has to be already presented.
    /// - parameter segue: The segue
    public func add(segue: Segue<N>) -> Flow<N> {
        .init(segues: segues.union([segue]))
    }

    /// Adds multiple one-to-one segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    public func add(
        segue: OneToOneSegues<N>,
        grant: SegueGrant = .pass,
        auto: Bool = false
    ) -> Flow<N> {
        add(rels: segue.rels, grant: grant, auto: auto)
    }

    /// Adds multiple one-to-many segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    /// - parameter grant: The grant type for all resulting segues. Defaults to `.pass`.
    /// - parameter auto: The auto firing behaviour for all resulting segues. Defaults to `false`.
    public func add(
        segue: OneToManySegues<N>,
        grant: SegueGrant = .pass,
        auto: Bool = false
    ) -> Flow<N> {
        add(rels: segue.rels, grant: grant, auto: auto)
    }

    /// Adds multiple many-to-one segues to the flow. The initial node has to be already presented.
    /// - parameter segue: The segues
    /// - parameter grant: The grant type for all resulting segues. Defaults to `.pass`.
    /// - parameter auto: The auto firing behaviour for all resulting segues. Defaults to `false`.
    public func add(
        segue: ManyToOneSegues<N>,
        grant: SegueGrant = .pass,
        auto: Bool = false
    ) -> Flow<N> {
        add(rels: segue.rels, grant: grant, auto: auto)
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

    /// Returns true if there are no segues in this flow
    public var isEmpty: Bool {
        segues.isEmpty
    }
}
