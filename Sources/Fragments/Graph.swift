//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation
import SwiftUI

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

public struct SegueTraitOperation<N: Node> {
    let graph: NavigationGraph<N>

    @discardableResult public func add(trait: SegueTrait<N>) -> Self {
        .init(graph: graph)
    }

    @discardableResult public func remove(trait: SegueTrait<N>) -> Self {
        .init(graph: graph)
    }
    
    @discardableResult public func clear() -> Self {
        .init(graph: graph)
    }
}

///
public class NavigationGraph<N: Node>: ObservableObject {
    public init(flow: Flow<N>) {}

    public func flow(reaching: N) -> Flow<N> {
        .init()
    }

    public func edit(segue: Segue<N>) -> SegueTraitOperation<N> {
        .init(graph: self)
    }

    public func edit(segue: OneToOneSegues<N>) -> SegueTraitOperation<N> {
        .init(graph: self)
    }

    public func edit(segue: OneToManySegues<N>) -> SegueTraitOperation<N> {
        .init(graph: self)
    }

    public func edit(segue: ManyToOneSegues<N>) -> SegueTraitOperation<N> {
        .init(graph: self)
    }

    public func present(node: N) {}

    public func present(flow: Flow<N>) {}

    public func next() {}

    public func prev() {}

    public func dismiss() {}

    public func isPresented(_ node: N) -> Bool {
        return true
    }

    public func isPresented(_ node: N) -> Binding<Bool> {
        return .constant(true)
    }
}
