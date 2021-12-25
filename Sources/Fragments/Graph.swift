//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation

/// A node is the atomic unit in a navigation graph. It usually represents a screen (or a part of it) in your app
public protocol Node: Hashable {}

public protocol SegueCollection {
    associatedtype N: Node
    var segues: [Segue<N>] { get }
}

precedencegroup GraphConnectorPrecedence {
    associativity: left
    assignment: false
}

infix operator =>: GraphConnectorPrecedence
infix operator <=>: GraphConnectorPrecedence

public extension Node {
    static func => (lhs: Self, rhs: Self) -> OneToOneSegues<Self> {
        return OneToOneSegues(segues: [Segue(lhs, to: rhs)])
    }

    static func => (lhs: Self, rhs: [Self]) -> OneToManySegues<Self> {
        return OneToManySegues(segues: rhs.map { Segue(lhs, to: $0) })
    }

    static func => (lhs: [Self], rhs: Self) -> ManyToOneSegues<Self> {
        return ManyToOneSegues(segues: lhs.map { Segue($0, to: rhs) })
    }

    static func <=> (lhs: Self, rhs: Self) -> OneToOneSegues<Self> {
        return OneToOneSegues(segues: [
            Segue(lhs, to: rhs),
            Segue(rhs, to: lhs)
        ])
    }

    static func <=> (lhs: [Self], rhs: Self) -> ManyToOneSegues<Self> {
        return ManyToOneSegues(segues: lhs.flatMap {
            [
                Segue(rhs, to: $0),
                Segue($0, to: rhs)
            ]
        })
    }

    static func <=> (lhs: Self, rhs: [Self]) -> OneToManySegues<Self> {
        return OneToManySegues(segues: rhs.flatMap {
            [
                Segue($0, to: lhs),
                Segue(lhs, to: $0)
            ]
        })
    }
}

public struct OneToOneSegues<N: Node>: SegueCollection {
    public let segues: [Segue<N>]

    public static func => (lhs: Self, rhs: N) -> Self {
        if let last = lhs.segues.last {
            return OneToOneSegues(segues: lhs.segues + [Segue(last.out, to: rhs)])
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func => (lhs: Self, rhs: [N]) -> ManyToOneSegues<N> {
        if let last = lhs.segues.last {
            return ManyToOneSegues(segues: lhs.segues + rhs.map { Segue(last.out, to: $0) })
        }
        else {
            return ManyToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> Self {
        if let last = lhs.segues.last {
            return OneToOneSegues(segues: lhs.segues + [
                Segue(last.out, to: rhs),
                Segue(rhs, to: last.out)
            ])
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: [N]) -> ManyToOneSegues<N> {
        if let last = lhs.segues.last {
            return ManyToOneSegues(segues: lhs.segues + rhs.flatMap {
                [
                    Segue(last.out, to: $0),
                    Segue($0, to: last.out)
                ]
            })
        }
        else {
            return ManyToOneSegues(segues: [])
        }
    }
}

public struct ManyToOneSegues<N: Node>: SegueCollection {
    public let segues: [Segue<N>]

    public static func => (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToOneSegues(segues: lhs.segues + segues.map { Segue($0.out, to: rhs) })
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func => (lhs: Self, rhs: [N]) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToOneSegues(segues: lhs.segues + segues.flatMap { a in
                rhs.map { Segue(a.out, to: $0) }
            })
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToOneSegues(segues: lhs.segues + segues.flatMap {
                [
                    Segue($0.out, to: rhs),
                    Segue(rhs, to: $0.out)
                ]
            })
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: [N]) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToOneSegues(segues: lhs.segues + segues.flatMap { a in
                rhs.flatMap {
                    [
                        Segue(a.out, to: $0),
                        Segue($0, to: a.out)
                    ]
                }
            })
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }
}

public struct OneToManySegues<N: Node>: SegueCollection {
    public let segues: [Segue<N>]
}

public struct Segue<N: Node> {
    let `in`: N
    let out: N

    /// Segues connect two nodes in a navigation graph forming a directed link.
    /// - parameter in: The input node (starting node)
    /// - parameter out: The output node (node to connect)
    public init(_ in: N, to out: N) {
        self.in = `in`
        self.out = out
    }
}

/// Segue traits define the navigation behaviour between nodes
public enum SegueTrait<N: Node>: Hashable {
    /// When navigating using next/prev commands, it points to the next node
    case next
    /// When navigating using next/prev commands, it points to the previous node
    case prev
    /// Redirects to another path which has to be reachable from the current navigation graph state
    case redirect(to: N)
    /// Disables the segue
    case disable
    /// Marks the segue as inclusive. Normal nodes are exclusive relative to their origin node.
    /// In other words, when navigating to a node, all its siblings become inactive, while itself becomes active.
    /// If a segue is marked `.inclusive`, this behaviour is disabled and multiple nodes can be active from the same parent node.
    case inclusive
    /// Similar to `.inclusive`. In addition, the closest active `.modal` node becomes inactive when calling navigation graph's `dismiss()` no matter the active graph layout.
    case modal
}

/// A flow contains multiple segue-connected nodes
public struct Flow<N: Node> {
    public init() {}
    /// Connects one node to another using a segue
    /// - parameter segue: The segue
    public mutating func add(segue: Segue<N>) {}

    /// Connects multiple nodes to a single one using multiple segues
    /// - parameter segue: The segue collection
    // We avoid using a protocol for all collection and use overriding because of a Swift typesystem the limitation: this way we can reference node without fully qualify it (i.e. `KeyScreen.home` vs `.home`)
    public mutating func add(segue: OneToOneSegues<N>) {}

    public mutating func add(segue: OneToManySegues<N>) {}

    public mutating func add(segue: ManyToOneSegues<N>) {}

    public mutating func add(trait: SegueTrait<N>, segue: Segue<N>) {}

    public mutating func add(trait: SegueTrait<N>, segue: OneToOneSegues<N>) {}

    public mutating func add(trait: SegueTrait<N>, segue: OneToManySegues<N>) {}

    public mutating func add(trait: SegueTrait<N>, segue: ManyToOneSegues<N>) {}
}

public class NavigationGraph<N: Node>: ObservableObject {
    public init(flow: Flow<N>) {}
}
