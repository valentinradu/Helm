//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation
import SwiftUI

/// A flow is a unique set of segues that connect two or more nodes.
public struct Flow<N: Node>: Hashable {
    var segues: [Segue<N>]
    
    public init() {
        segues = []
    }
    /// Connects one node to another using a segue
    /// - parameter segue: The segue
    public mutating func add(segue: Segue<N>) {}

    /// Connects multiple nodes to a single one using multiple segues
    /// - parameter segue: The segue collection
    // We avoid using a protocol for all collection and use overriding because of a Swift typesystem the limitation: this way we can reference node without fully qualify it (i.e. `KeyScreen.home` vs `.home`)
    public mutating func add(segue: OneToOneSegues<N>) {}

    public mutating func add(segue: OneToManySegues<N>) {}

    public mutating func add(segue: ManyToOneSegues<N>) {}
}

public class NavigationGraph<N: Node>: ObservableObject {
    public init(flow: Flow<N>) {}

    public func path(to: N) -> Flow<N> {
        .init()
    }

    public func path(from: Segue<N>) -> Flow<N> {
        .init()
    }

    public func path(from: OneToOneSegues<N>) -> Flow<N> {
        .init()
    }

    public func path(from: OneToManySegues<N>) -> Flow<N> {
        .init()
    }

    public func path(from: ManyToOneSegues<N>) -> Flow<N> {
        .init()
    }

    public func add(trait: SegueTrait<N>, segue: Segue<N>) {}
    
    public func add(trait: SegueTrait<N>, segue: OneToOneSegues<N>) {}
    
    public func add(trait: SegueTrait<N>, segue: OneToManySegues<N>) {}
    
    public func add(trait: SegueTrait<N>, segue: ManyToOneSegues<N>) {}

    public func present(node: N) {}

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
