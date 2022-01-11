//
//  File.swift
//
//
//  Created by Valentin Radu on 07/01/2022.
//

import Collections
import Foundation

/// A node in the graph
public protocol Node: Hashable {}

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
        var visited: Set<Element.N> = []
        for segue in dfs() {
            if visited.contains(segue.out) {
                return true
            } else {
                visited.insert(segue.out)
            }
        }
        return false
    }

    /// Returns all the edges that leave a specific node
    /// - parameter for: The node from which the edges leave
    func egressEdges(for node: Element.N) -> Set<Element> {
        Set(filter { $0.in == node })
    }

    /// Returns all the edges that leave a set of nodes
    /// - parameter for: The node from which the edges leave
    func egressEdges(for nodes: Set<Element.N>) -> Set<Element> {
        Set(
            nodes.flatMap {
                egressEdges(for: $0)
            }
        )
    }

    /// Returns an unique egress edge from a given node.
    /// - throws: If multiple edges leave the node.
    /// - throws: If no edges leave the node.
    func uniqueEgressEdge(for node: Element.N) throws -> Element {
        let edges = egressEdges(for: node)
        guard edges.count > 0 else {
            throw HelmError<Element>.missingEgressEdges(from: node)
        }
        guard edges.count == 1 else {
            throw HelmError<Element>.ambiguousEgressEdges(edges, from: node)
        }
        return edges.first!
    }

    /// Returns all the edges that arrive to a specific node
    /// - parameter for: The destination node
    func ingressEdges(for node: Element.N) -> Set<Element> {
        Set(filter { $0.out == node })
    }

    /// Returns all the edges that arrive to a set of nodes
    /// - parameter for: The destination nodes
    func ingressEdges(for nodes: Set<Element.N>) -> Set<Element> {
        Set(
            nodes.flatMap {
                ingressEdges(for: $0)
            }
        )
    }

    /// Returns an unique ingress edge towards a given node.
    /// - throws: If multiple edges lead to the node.
    /// - throws: If no edges lead to the node.
    func uniqueIngressEdge(for node: Element.N) throws -> Element {
        let edges = ingressEdges(for: node)
        guard edges.count > 0 else {
            throw HelmError<Element>.missingIngressEdges(from: node)
        }
        guard edges.count == 1 else {
            throw HelmError<Element>.ambiguousIngressEdges(edges, from: node)
        }
        return edges.first!
    }

    /// Inlets are edges that are unconnected with the graph at their `in` node.
    /// They can be seen as entry points in a directed graph.
    var inlets: Set<Element> {
        let ins = Set(map { $0.in })
        let outs = Set(map { $0.out })
        return egressEdges(for: Set(ins.subtracting(outs)))
    }

    /// Outlets are edges that are unconnected with the graph at their `out` node.
    /// They can be seen as exit points in a directed graph.
    var outlets: Set<Element> {
        let ins = Set(map { $0.in })
        let outs = Set(map { $0.out })
        return ingressEdges(for: Set(outs.subtracting(ins)))
    }

    var nodes: Set<Element.N> {
        Set(flatMap { [$0.in, $0.out] })
    }

    var disconnectedSubgraphs: OrderedSet<Set<Element>> {
        var labels: [Element: Int] = [:]
        var currentLabel = 0

        for segue in self {
            guard labels[segue] == nil else {
                continue
            }
            for nextSegue in dfs(from: segue.in) {
                labels[nextSegue] = currentLabel
            }
            currentLabel += 1
        }

        let result = Dictionary(grouping: labels, by: { $0.value })
            .values
            .map {
                Set($0.map { $0.key })
            }

        return OrderedSet(result)
    }

    /// Iterates through the entire graph or a section of it (starting at a given node) depth first. Edges leading to the same node are iterated.
    /// - parameter from: An optional start node. If not provided, the entire graph will be iterated.
    /// - returns: An ordered set containing all the iterated segues in the right order.
    func dfs(from: Element.N? = nil) -> OrderedSet<Element> {
        var visited: OrderedSet<Element> = []
        let entries: Set<Element>

        if let from = from {
            entries = egressEdges(for: from)
        } else if inlets.count > 0 {
            entries = inlets
        } else if let first = first {
            entries = [first]
        } else {
            return []
        }

        for entry in entries {
            var stack: [Element] = [entry]

            while let edge = stack.last {
                let nextEdges = filter {
                    $0.in == edge.out && !visited.contains($0)
                }

                if let nextEdge = nextEdges.first {
                    visited.append(nextEdge)
                    stack.append(nextEdge)
                } else {
                    stack.removeLast()
                }
            }
        }

        return visited
    }
}

extension Set: EdgeCollection {}
extension OrderedSet: EdgeCollection {}

public struct Walker<C: DirectedConnectable> {
    let graph: Set<C>
}
