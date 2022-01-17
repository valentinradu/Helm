//
//  File.swift
//
//
//  Created by Valentin Radu on 14/01/2022.
//

import Foundation

/// The precedence group used for the directed edges operators.
precedencegroup DirectedConnectorPrecedence {
    associativity: left
    assignment: false
}

/// The one way connector operator
infix operator =>: DirectedConnectorPrecedence

public func => <N: Node>(lhs: N, rhs: N) -> DirectedEdge<N> {
    return DirectedEdge(from: lhs, to: rhs)
}

public func => <N: Node>(lhs: N, rhs: Set<N>) -> Set<DirectedEdge<N>> {
    return Set(rhs.map {
        DirectedEdge(from: lhs, to: $0)
    })
}

public func => <N: Node>(lhs: Set<N>, rhs: N) -> Set<DirectedEdge<N>> {
    return Set(lhs.map {
        DirectedEdge(from: $0, to: rhs)
    })
}

public func => <N: Node>(lhs: DirectedEdge<N>, rhs: N) -> Set<DirectedEdge<N>> {
    return [
        lhs,
        DirectedEdge(from: lhs.to, to: rhs),
    ]
}

public func => <N: Node>(lhs: DirectedEdge<N>, rhs: Set<N>) -> Set<DirectedEdge<N>> {
    return Set([lhs] + rhs.map {
        DirectedEdge(from: lhs.to, to: $0)
    })
}

public func => <N: Node>(lhs: Set<DirectedEdge<N>>, rhs: N) -> Set<DirectedEdge<N>> {
    return Set(lhs + lhs.outlets.map {
        DirectedEdge(from: $0.to, to: rhs)
    })
}

public func => <N: Node>(lhs: Set<DirectedEdge<N>>, rhs: Set<N>) -> Set<DirectedEdge<N>> {
    return Set(lhs + lhs.outlets.flatMap { outlet in
        rhs.map {
            DirectedEdge(from: outlet.to, to: $0)
        }
    })
}
