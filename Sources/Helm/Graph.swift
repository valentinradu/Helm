//
//  File.swift
//
//
//  Created by Valentin Radu on 07/01/2022.
//

import Collections
import Foundation

/// A node in the graph
public protocol Node: Hashable, CustomDebugStringConvertible {}

/// The undirected relationship between two nodes.
public protocol UndirectedConnectable: Hashable {
    associatedtype N: Node
    /// The input node
    var lhs: N { get }
    /// The output node
    var rhs: N { get }
}

public extension CustomDebugStringConvertible where Self: UndirectedConnectable {
    var debugDescription: String {
        return "\(lhs) - \(rhs)"
    }
}

/// The directed relationship between two nodes.
public protocol DirectedConnectable: Hashable {
    associatedtype N: Node
    /// The input node
    var `in`: N { get }
    /// The output node
    var out: N { get }
}

public extension CustomDebugStringConvertible where Self: DirectedConnectable {
    var debugDescription: String {
        return "\(`in`) -> \(out)"
    }
}

/// An edge between two nodes
public struct Edge<N: Node>: UndirectedConnectable {
    public let lhs: N
    public let rhs: N
}

/// An directed edge between two nodes
public struct DirectedEdge<N: Node>: DirectedConnectable {
    public let `in`: N
    public let out: N
}

/// A collection of edges.
public protocol EdgeCollection: Collection & Hashable & Sequence {}

public extension EdgeCollection where Element: Hashable {
    /// Checks if the graph has a specific edge.
    /// - parameter edge: The edge to search for
    func has(edge: Element) -> Bool {
        contains(edge)
    }
}

public extension EdgeCollection where Element: UndirectedConnectable {
    /// Checks if the graph has a specific node.
    /// - parameter node: The node to search for
    func has(node: Element.N) -> Bool {
        contains(where: {
            $0.rhs == node || $0.lhs == node
        })
    }
}

public extension EdgeCollection where Element: DirectedConnectable {
    /// Checks if the graph has a specific node.
    /// - parameter node: The node to search for
    func has(node: Element.N) -> Bool {
        contains(where: {
            $0.in == node || $0.out == node
        })
    }

    // Detect if the graph has cycles
    var hasCycle: Bool {
        firstCycle != nil
    }

    // Returns the first cycle it encounters, if any.
    var firstCycle: GraphPath<Element>? {
        guard let first = first else {
            return nil
        }

        var visited: Set<Element.N> = []
        var segues: OrderedSet<Element> = inlets.count > 0 ? inlets : [first]
        var path: OrderedSet<Element> = []
        var stack: [(OrderedSet<Element>, OrderedSet<Element>)] = []

        while segues.count > 0 {
            let segue = segues.removeFirst()

            if !visited.contains(segue.out) {
                let outs = egressEdges(for: segue.out)
                if outs.count > 0 {
                    if segues.count > 0 {
                        stack.append((path, segues))
                    }
                    segues = outs
                }
                visited.insert(segue.out)
                path.append(segue)
            } else {
                let cycle = path.drop(while: { $0.in != segue.out }) + [segue]
                guard cycle.count > 1 else {
                    assertionFailure("A cycle should have at least 2 edges.")
                    return nil
                }
                return OrderedSet(cycle)
            }

            if segues.count == 0 {
                if let (nextPath, nextSegues) = stack.popLast() {
                    path = nextPath
                    segues = nextSegues
                }
            }
        }

        return nil
    }

    /// Returns all the edges that leave a specific node
    /// - parameter for: The node from which the edges leave
    func egressEdges(for node: Element.N) -> OrderedSet<Element> {
        OrderedSet(filter { $0.in == node })
    }

    /// Returns all the edges that leave a set of nodes
    /// - parameter for: The node from which the edges leave
    func egressEdges(for nodes: OrderedSet<Element.N>) -> OrderedSet<Element> {
        OrderedSet(
            nodes.flatMap {
                egressEdges(for: $0)
            }
        )
    }

    /// Returns an unique egress edge from a given node.
    /// - throws: If multiple segues leave the node.
    /// - throws: If no segues leave the node.
    func uniqueEgressEdge(for node: Element.N) throws -> Element {
        let segues = egressEdges(for: node)
        guard segues.count > 0 else {
            throw GraphError.missingEgress(node: node)
        }
        guard segues.count == 1 else {
            throw GraphError.ambiguousEgress(node: node, segues: segues)
        }
        return segues.first!
    }

    /// Returns all the edges that arrive to a specific node
    /// - parameter for: The destination node
    func ingressEdges(for node: Element.N) -> OrderedSet<Element> {
        OrderedSet(filter { $0.out == node })
    }

    /// Returns all the edges that arrive to a set of nodes
    /// - parameter for: The destination nodes
    func ingressEdges(for nodes: OrderedSet<Element.N>) -> OrderedSet<Element> {
        OrderedSet(
            nodes.flatMap {
                ingressEdges(for: $0)
            }
        )
    }

    /// Returns an unique ingress edge towards a given node.
    /// - throws: If multiple segues lead to the node.
    /// - throws: If no segues lead to the node.
    func uniqueIngressEdge(for node: Element.N) throws -> Element {
        let segues = ingressEdges(for: node)
        guard segues.count > 0 else {
            throw GraphError.missingIngress(node: node)
        }
        guard segues.count == 1 else {
            throw GraphError.ambiguousIngress(node: node, segues: segues)
        }
        return segues.first!
    }

    /// Inlets are edges that are unconnected with the graph at their `in` node.
    /// They can be seen as entry points in a directed graph.
    var inlets: OrderedSet<Element> {
        let ins = Set(map { $0.in })
        let outs = Set(map { $0.out })
        return egressEdges(for: OrderedSet(ins.subtracting(outs)))
    }

    /// Outlets are edges that are unconnected with the graph at their `out` node.
    /// They can be seen as exit points in a directed graph.
    var outlets: OrderedSet<Element> {
        let ins = Set(map { $0.in })
        let outs = Set(map { $0.out })
        return ingressEdges(for: OrderedSet(outs.subtracting(ins)))
    }

    var nodes: OrderedSet<Element.N> {
        OrderedSet(flatMap { [$0.in, $0.out] })
    }
}

extension OrderedSet: EdgeCollection {}
extension Set: EdgeCollection {}

/// A graph is a collection of unordered edges
public typealias Graph<E: UndirectedConnectable> = Set<E>
/// A directed graph is a collection of unordered directed edges
public typealias DirectedGraph<E: DirectedConnectable> = Set<E>
/// A directed path is a collection of ordered directed edges
public typealias GraphPath<E: DirectedConnectable> = OrderedSet<E>

public struct Walker<C: DirectedConnectable> {
    let graph: DirectedGraph<C>
    func dfs() {
        guard let first = graph.first else {
            return
        }

        let inlets = graph.inlets
        var visited: Set<C.N> = []
        var segues: OrderedSet<C> = inlets.count > 0 ? inlets : [first]
        var stack: [OrderedSet<C>] = []

        while segues.count > 0 {
            let segue = segues.removeFirst()

            if !visited.contains(segue.out) {
                let outs = graph.egressEdges(for: segue.out)
                if outs.count > 0 {
                    if segues.count > 0 {
                        stack.append(segues)
                    }
                    segues = outs
                }
                visited.insert(segue.out)
            }

            if segues.count == 0 {
                if let next = stack.popLast() {
                    segues = next
                }
            }
        }
    }
}
