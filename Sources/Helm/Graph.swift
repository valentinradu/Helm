//
//  File.swift
//
//
//  Created by Valentin Radu on 07/01/2022.
//

import Collections
import Foundation

/// A node in the graph
public protocol Node: Hashable, Comparable {}

/// The directed relationship between two nodes.
public protocol DirectedConnectable: Hashable, Comparable, CustomDebugStringConvertible {
    associatedtype N: Node
    /// The input node
    var from: N { get }
    /// The output node
    var to: N { get }
}

public extension CustomDebugStringConvertible where Self: DirectedConnectable {
    var debugDescription: String {
        return "\(from) -> \(to)"
    }
}

public extension Comparable where Self: DirectedConnectable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.from == rhs.from {
            return lhs.to < rhs.to
        } else {
            return lhs.from < rhs.from
        }
    }
}

/// An directed edge between two nodes
public struct DirectedEdge<N: Node>: DirectedConnectable {
    public let from: N
    public let to: N
    public init(from: N, to: N) {
        self.from = from
        self.to = to
    }
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
            $0.from == node || $0.to == node
        })
    }

    // Detect if the graph has cycles
    var hasCycle: Bool {
        var visited: Set<Element> = []
        
        
        guard count > 0 else {
            return false
        }
        
        guard inlets.count > 0 else {
            return true
        }

        for entry in inlets {
            var stack: [Element] = [entry]

            while let edge = stack.last {
                visited.insert(edge)

                let nextEdges =
                    filter { $0.from == edge.to && !visited.contains($0) }
                        .sorted()
                
                let stackNodes = Set(stack.flatMap { [$0.from, $0.to] })
                let nextEdgesNodes = Set(nextEdges.map { $0.to })
                
                if !stackNodes.isDisjoint(with: nextEdgesNodes) {
                    return true
                }

                if let nextEdge = nextEdges.first {
                    stack.append(nextEdge)
                } else {
                    stack.removeLast()
                }
            }
        }

        return false
    }

    /// Returns all the edges that leave a specific node
    /// - parameter for: The node from which the edges leave
    func egressEdges(for node: Element.N) -> Set<Element> {
        Set(filter { $0.from == node })
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
        Set(filter { $0.to == node })
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
            throw HelmError<Element>.missingIngressEdges(to: node)
        }
        guard edges.count == 1 else {
            throw HelmError<Element>.ambiguousIngressEdges(edges, to: node)
        }
        return edges.first!
    }

    /// Inlets are edges that are unconnected with the graph at their `in` node.
    /// They can be seen as entry points in a directed graph.
    var inlets: Set<Element> {
        let ins = Set(map { $0.from })
        let outs = Set(map { $0.to })
        return egressEdges(for: Set(ins.subtracting(outs)))
    }

    /// Outlets are edges that are unconnected with the graph at their `out` node.
    /// They can be seen as exit points in a directed graph.
    var outlets: Set<Element> {
        let ins = Set(map { $0.from })
        let outs = Set(map { $0.to })
        return ingressEdges(for: Set(outs.subtracting(ins)))
    }

    var nodes: Set<Element.N> {
        Set(flatMap { [$0.from, $0.to] })
    }

    var disconnectedSubgraphs: OrderedSet<Set<Element>> {
        var labels: [Element: Int] = [:]
        var currentLabel = 0

        for segue in self {
            guard labels[segue] == nil else {
                continue
            }
            for nextSegue in dfs(from: segue.from) {
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

    /// Iterates through the entire graph or a fragment of it (starting at a given node) depth first. Edges leading to the same node are iterated.
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

        for entry in entries.sorted() {
            var stack: [Element] = [entry]

            while let edge = stack.last {
                visited.append(edge)

                let nextEdges =
                    filter {
                        $0.from == edge.to && !visited.contains($0)
                    }
                    .sorted()

                if let nextEdge = nextEdges.first {
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
