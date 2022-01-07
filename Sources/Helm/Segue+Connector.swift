//
//  File.swift
//  
//
//  Created by Valentin Radu on 06/01/2022.
//

import Foundation
import OrderedCollections

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
        return OneToOneSegues(rels: [SegueRel(lhs, to: rhs)])
    }

    static func => (lhs: Self, rhs: OrderedSet<Self>) -> OneToManySegues<Self> {
        let set = OrderedSet(rhs.map { SegueRel(lhs, to: $0) })
        return OneToManySegues(rels: set)
    }

    static func => (lhs: OrderedSet<Self>, rhs: Self) -> ManyToOneSegues<Self> {
        let set = OrderedSet(lhs.map { SegueRel($0, to: rhs) })
        return ManyToOneSegues(rels: set)
    }

    static func <=> (lhs: Self, rhs: Self) -> OneToOneSegues<Self> {
        return OneToOneSegues(rels: [
            SegueRel(lhs, to: rhs),
            SegueRel(rhs, to: lhs)
        ])
    }

    static func <=> (lhs: OrderedSet<Self>, rhs: Self) -> ManyToOneSegues<Self> {
        let set = OrderedSet(lhs.flatMap {
            [
                SegueRel($0, to: rhs),
                SegueRel(rhs, to: $0)
            ]
        })
        return ManyToOneSegues(rels: set)
    }

    static func <=> (lhs: Self, rhs: OrderedSet<Self>) -> OneToManySegues<Self> {
        let set = OrderedSet(rhs.flatMap {
            [
                SegueRel(lhs, to: $0),
                SegueRel($0, to: lhs)
            ]
        })
        return OneToManySegues(rels: set)
    }
}

/// One-to-one segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct OneToOneSegues<N: Node> {
    let rels: OrderedSet<SegueRel<N>>

    public static func => (lhs: Self, rhs: N) -> Self {
        if let last = lhs.rels.last {
            let set = lhs.rels.union([SegueRel(last.out, to: rhs)])
            return OneToOneSegues(rels: set)
        }
        else {
            return OneToOneSegues(rels: [])
        }
    }

    public static func => (lhs: Self, rhs: OrderedSet<N>) -> OneToManySegues<N> {
        if let last = lhs.rels.last {
            return OneToManySegues(rels: lhs.rels.union(rhs.map { SegueRel(last.out, to: $0) }))
        }
        else {
            return OneToManySegues(rels: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> Self {
        if let last = lhs.rels.last {
            let set = OrderedSet(lhs.rels + [
                SegueRel(last.in, to: rhs),
                SegueRel(rhs, to: last.in)
            ])
            return OneToOneSegues(rels: set)
        }
        else {
            return OneToOneSegues(rels: [])
        }
    }

    public static func <=> (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.rels.last {
            let set = OrderedSet(lhs.rels + rhs.flatMap {
                [
                    SegueRel(last.in, to: $0),
                    SegueRel($0, to: last.in)
                ]
            })
            return OneToManySegues(rels: set)
        }
        else {
            return OneToManySegues(rels: [])
        }
    }
}

/// Many-to-one segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct ManyToOneSegues<N: Node> {
    let rels: OrderedSet<SegueRel<N>>

    public static func => (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.rels.last {
            let rels = lhs.rels.filter { $0.out == last.out }
            let set = OrderedSet(lhs.rels + rels.map { SegueRel($0.out, to: rhs) })
            return OneToOneSegues(rels: set)
        }
        else {
            return OneToOneSegues(rels: [])
        }
    }

    public static func => (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.rels.last {
            let rels = lhs.rels.filter { $0.out == last.out }
            let set = OrderedSet(lhs.rels + rels.flatMap { a in
                rhs.map { SegueRel(a.out, to: $0) }
            })
            return OneToManySegues(rels: set)
        }
        else {
            return OneToManySegues(rels: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> OneToOneSegues<N> {
        if let last = lhs.rels.last {
            let rels = lhs.rels.filter { $0.in == last.in }
            let set = OrderedSet(lhs.rels + rels.flatMap {
                [
                    SegueRel($0.in, to: rhs),
                    SegueRel(rhs, to: $0.in)
                ]
            })
            return OneToOneSegues(rels: set)
        }
        else {
            return OneToOneSegues(rels: [])
        }
    }

    public static func <=> (lhs: Self, rhs: [N]) -> OneToManySegues<N> {
        if let last = lhs.rels.last {
            let rels = lhs.rels.filter { $0.in == last.in }
            let set = OrderedSet(lhs.rels + rels.flatMap { a in
                rhs.flatMap {
                    [
                        SegueRel(a.in, to: $0),
                        SegueRel($0, to: a.in)
                    ]
                }
            })
            return OneToManySegues(rels: set)
        }
        else {
            return OneToManySegues(rels: [])
        }
    }
}

/// One-to-many segues allow creating complex relationships between nodes in a graph using the segue connectors.
public struct OneToManySegues<N: Node> {
    let rels: OrderedSet<SegueRel<N>>

    public static func => (lhs: Self, rhs: N) -> ManyToOneSegues<N> {
        if let last = lhs.rels.last {
            let rels = lhs.rels.filter { $0.in == last.in }
            let set = OrderedSet(lhs.rels + rels.map { SegueRel($0.out, to: rhs) })
            return ManyToOneSegues(rels: set)
        }
        else {
            return ManyToOneSegues(rels: [])
        }
    }

    public static func <=> (lhs: Self, rhs: N) -> ManyToOneSegues<N> {
        if let last = lhs.rels.last {
            let rels = lhs.rels.filter { $0.in == last.out }
            let set = OrderedSet(lhs.rels + rels.flatMap {
                [
                    SegueRel($0.out, to: rhs),
                    SegueRel(rhs, to: $0.out)
                ]
            })
            return ManyToOneSegues(rels: set)
        }
        else {
            return ManyToOneSegues(rels: [])
        }
    }
}
