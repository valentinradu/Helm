//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation
import OrderedCollections

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

    static func => (lhs: Self, rhs: OrderedSet<Self>) -> OneToManySegues<Self> {
        let set = OrderedSet(rhs.map { Segue(lhs, to: $0) })
        return OneToManySegues(segues: set)
    }

    static func => (lhs: OrderedSet<Self>, rhs: Self) -> ManyToOneSegues<Self> {
        let set = OrderedSet(lhs.map { Segue($0, to: rhs) })
        return ManyToOneSegues(segues: set)
    }

    static func <=> (lhs: Self, rhs: Self) -> OneToOneSegues<Self> {
        return OneToOneSegues(segues: [
            Segue(lhs, to: rhs),
            Segue(rhs, to: lhs)
        ])
    }

    static func <=> (lhs: OrderedSet<Self>, rhs: Self) -> ManyToOneSegues<Self> {
        let set = OrderedSet(lhs.flatMap {
            [
                Segue($0, to: rhs),
                Segue(rhs, to: $0)
            ]
        })
        return ManyToOneSegues(segues: set)
    }

    static func <=> (lhs: Self, rhs: OrderedSet<Self>) -> OneToManySegues<Self> {
        let set = OrderedSet(rhs.flatMap {
            [
                Segue(lhs, to: $0),
                Segue($0, to: lhs)
            ]
        })
        return OneToManySegues(segues: set)
    }
}

/// One-to-one segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct OneToOneSegues<N: Node> {
    let segues: OrderedSet<Segue<N>>

    public static func => (lhs: Self, rhs: N) -> Self {
        if let last = lhs.segues.last {
            let set = lhs.segues.union([Segue(last.out, to: rhs)])
            return OneToOneSegues(segues: set)
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func => (lhs: Self, rhs: OrderedSet<N>) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            return OneToManySegues(segues: lhs.segues.union(rhs.map { Segue(last.out, to: $0) }))
        }
        else {
            return OneToManySegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> Self {
        if let last = lhs.segues.last {
            let set = OrderedSet(lhs.segues + [
                Segue(last.in, to: rhs),
                Segue(rhs, to: last.in)
            ])
            return OneToOneSegues(segues: set)
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            let set = OrderedSet(lhs.segues + rhs.flatMap {
                [
                    Segue(last.in, to: $0),
                    Segue($0, to: last.in)
                ]
            })
            return OneToManySegues(segues: set)
        }
        else {
            return OneToManySegues(segues: [])
        }
    }
}

/// Many-to-one segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct ManyToOneSegues<N: Node> {
    let segues: OrderedSet<Segue<N>>

    public static func => (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            let set = OrderedSet(lhs.segues + segues.map { Segue($0.out, to: rhs) })
            return OneToOneSegues(segues: set)
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func => (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.out == last.out }
            let set = OrderedSet(lhs.segues + segues.flatMap { a in
                rhs.map { Segue(a.out, to: $0) }
            })
            return OneToManySegues(segues: set)
        }
        else {
            return OneToManySegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.in == last.in }
            let set = OrderedSet(lhs.segues + segues.flatMap {
                [
                    Segue($0.in, to: rhs),
                    Segue(rhs, to: $0.in)
                ]
            })
            return OneToOneSegues(segues: set)
        }
        else {
            return OneToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.in == last.in }
            let set = OrderedSet(lhs.segues + segues.flatMap { a in
                rhs.flatMap {
                    [
                        Segue(a.in, to: $0),
                        Segue($0, to: a.in)
                    ]
                }
            })
            return OneToManySegues(segues: set)
        }
        else {
            return OneToManySegues(segues: [])
        }
    }
}

/// One-to-many segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct OneToManySegues<N: Node> {
    public let segues: OrderedSet<Segue<N>>

    public static func => (lhs: Self, rhs: N) -> ManyToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.in == last.in }
            let set = OrderedSet(lhs.segues + segues.map { Segue($0.out, to: rhs) })
            return ManyToOneSegues(segues: set)
        }
        else {
            return ManyToOneSegues(segues: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> ManyToOneSegues<N> {
        if let last = lhs.segues.last {
            let segues = lhs.segues.filter { $0.in == last.out }
            let set = OrderedSet(lhs.segues + segues.flatMap {
                [
                    Segue($0.out, to: rhs),
                    Segue(rhs, to: $0.out)
                ]
            })
            return ManyToOneSegues(segues: set)
        }
        else {
            return ManyToOneSegues(segues: [])
        }
    }
}

public struct Segue<N: Node>: Hashable, CustomDebugStringConvertible {
    let `in`: N
    let out: N

    /// Segues are the edges between the navigation graph's nodes.
    /// - parameter in: The input node (starting node)
    /// - parameter out: The output node (node to connect)
    public init(_ in: N, to out: N) {
        self.in = `in`
        self.out = out
    }

    public var debugDescription: String {
        return "\(self.in) => \(out)"
    }
}

/// Segue traits define the navigation rules between nodes.
/// Each segue can have multiple rules, editable at any time in the app's lifecycle.
public enum SegueTrait<N: Node>: Hashable {
    // Automatically activates the segue once its `in` node has been presented.
    case auto
    /// Forwards the navigation to another flow.
    /// The new flow has to be reachable. In other words, the first node in the flow has to be already presented.
    case redirect(to: Flow<N>)
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
    let segues: Set<Segue<N>>

    /// Adds a new trait to the selected segue/segues
    @discardableResult public func add(trait: SegueTrait<N>) -> Self {
        for segue in segues {
            if graph.traits[segue] == nil {
                graph.traits[segue] = Set()
            }
            graph.traits[segue]!.insert(trait)
        }
        return .init(graph: graph, segues: segues)
    }

    /// Removes a trait from the selected segue/segues. If the trait is not present, the operation *silently* fails.
    @discardableResult public func remove(trait: SegueTrait<N>) -> Self {
        for segue in segues {
            if graph.traits[segue] == nil {
                continue
            }
            graph.traits[segue]!.remove(trait)
            if graph.traits[segue]!.isEmpty {
                graph.traits.removeValue(forKey: segue)
            }
        }
        return .init(graph: graph, segues: segues)
    }

    /// Clears all the traits from the selected segue/segues. If the segues have no traits, the operation *silently* fails.
    @discardableResult public func clear() -> Self {
        for segue in segues {
            graph.traits.removeValue(forKey: segue)
        }
        return .init(graph: graph, segues: segues)
    }

    /// Filters the traits on the selected set of segues.
    @discardableResult public func filter(_ isIncluded: (SegueTrait<N>) -> Bool) -> Self {
        for segue in segues {
            if graph.traits[segue] == nil {
                continue
            }
            graph.traits[segue] = graph.traits[segue]!.filter(isIncluded)
        }
        return .init(graph: graph, segues: segues)
    }
}
