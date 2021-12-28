//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

/// A node is the atomic unit in a navigation graph. It usually represents a screen or a part of a screen in your app.
public protocol Node: Hashable {}

/// The precedence group used for the segue connector operators.
precedencegroup SegueConnectorPrecedence {
    associativity: left
    assignment: false
}

/// The one way graph connector operator
infix operator =>: SegueConnectorPrecedence

/// The two-way graph connector operator
infix operator <=>: SegueConnectorPrecedence

/// Extend the node for segue connector operators
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

/// One-to-one segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct OneToOneSegues<N: Node> {
    let segues: [Segue<N>]

    public static func => (lhs: Self, rhs: N) -> Self {
        if let last = lhs.segues.last {
            return OneToOneSegues(segues: lhs.segues + [Segue(last.out, to: rhs)])
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func => (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            return OneToManySegues(segues: lhs.segues + rhs.map { Segue(last.out, to: $0) })
        }
        else {
            return OneToManySegues(segues: [])
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

    public static func <=> (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            return OneToManySegues(segues: lhs.segues + rhs.flatMap {
                [
                    Segue(last.out, to: $0),
                    Segue($0, to: last.out)
                ]
            })
        }
        else {
            return OneToManySegues(segues: [])
        }
    }
}

/// Many-to-one segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct ManyToOneSegues<N: Node> {
    let segues: [Segue<N>]

    public static func => (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToOneSegues(segues: lhs.segues + segues.map { Segue($0.out, to: rhs) })
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func => (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToManySegues(segues: lhs.segues + segues.flatMap { a in
                rhs.map { Segue(a.out, to: $0) }
            })
        }
        else {
            return OneToManySegues(segues: [])
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

    public static func <=> (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            return OneToManySegues(segues: lhs.segues + segues.flatMap { a in
                rhs.flatMap {
                    [
                        Segue(a.out, to: $0),
                        Segue($0, to: a.out)
                    ]
                }
            })
        }
        else {
            return OneToManySegues(segues: [])
        }
    }
}

/// One-to-many segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct OneToManySegues<N: Node> {
    public let segues: [Segue<N>]

    public static func => (lhs: Self, rhs: N) -> ManyToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.in == last.in }
            return ManyToOneSegues(segues: lhs.segues + segues.map { Segue($0.out, to: rhs) })
        }
        else {
            return ManyToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> ManyToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.in == last.in }
            return ManyToOneSegues(segues: lhs.segues + segues.flatMap {
                [
                    Segue($0.out, to: rhs),
                    Segue(rhs, to: $0.out)
                ]
            })
        }
        else {
            return ManyToOneSegues(segues: [])
        }
    }
}

public struct Segue<N: Node>: Hashable {
    let `in`: N
    let out: N

    /// Segues are the edges between the navigation graph's nodes.
    /// - parameter in: The input node (starting node)
    /// - parameter out: The output node (node to connect)
    public init(_ in: N, to out: N) {
        self.in = `in`
        self.out = out
    }
}

/// Segue traits define the navigation rules between nodes.
/// Each segue can have multiple rules, editable at any time in the app's lifecycle.
public enum SegueTrait<N: Node>: Hashable {
    /// Used to determine the next node when calling the relative `.next()` command.
    /// Only one segue can have the `.next` trait between siblings.
    case next
    /// Used to determine the prev node when calling the relative `.prev()` command.
    /// /// Only one segue can have the `.prev` trait between siblings.
    case prev
    /// Forwards the navigation to another flow.
    /// The new flow has to be reachable. In other words, at least one node has to be at a segue's distance from the currently presented ones.
    case forward(flow: Flow<N>)
    /// Disables the segue. For all purposes, the segue behaves as it was never created.
    case disabled
    /// Presents the segue's out node by overlapping it with its siblings instead of replacing them.
    /// Nodes connected by normal segues are exclusive relative to their siblings.
    /// In other words, when navigating to a node, all its siblings become inactive, while itself becomes active (presented).
    /// If a segue is marked `.cover`, this behaviour is disabled and multiple nodes can be presented from the same parent node.
    case cover
    /// Used when calling the relative `.dismiss()` command to determine the closest context node that should be dismissed.
    case context
    /// Convenience trait combining `.cover` and `.context`
    case modal
}

/// Operations are returned by the graph's `edit(segue:)` method and mutate one or multiple segues.
public struct SegueTraitOperation<N: Node> {
    let graph: NavigationGraph<N>

    /// Adds a new trait to the selected segue/segues
    @discardableResult public func add(trait: SegueTrait<N>) -> Self {
        .init(graph: graph)
    }

    /// Removes a trait from the selected segue/segues. If the trait is not present, the operation *silently* fails.
    @discardableResult public func remove(trait: SegueTrait<N>) -> Self {
        .init(graph: graph)
    }

    /// Clears all the traits from the selected segue/segues. If the segues have no traits, the operation *silently* fails.
    @discardableResult public func clear() -> Self {
        .init(graph: graph)
    }

    /// Filters the traits on the selected set of segues.
    @discardableResult public func filter(_ isIncluded: (SegueTrait<N>) -> Bool) -> Self {
        .init(graph: graph)
    }
}
