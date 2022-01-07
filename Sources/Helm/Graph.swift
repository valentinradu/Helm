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

    /// Returns all the edges that leave a specific node
    /// - parameter for: The node from which the edges leave
    func egressEdges(for node: Element.N) -> Set<Element> {
        Set(filter { $0.in == node })
    }

    /// Returns all the edges that arrive to a specific node
    /// - parameter for: The node to which the edges arrive
    func ingressEdges(for node: Element.N) -> Set<Element> {
        Set(filter { $0.out == node })
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
