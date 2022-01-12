//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Foundation

public enum HelmError<E: DirectedConnectable>: Error {
    case empty
    case emptyPath
    case missingInlets
    case ambiguousInlets
    case ambiguousForwardInlets
    case oneEdgeToManySegues(Set<E>)
    case autoCycleDetected(Set<E>)
    case pathMismatch(Set<E>)
    case ambiguousAutoSegues(Set<E>)
    case missingTaggedSegue(name: AnyHashable)
    case fragmentNotPresented(E.N)
    case fragmentMissingDismissableSegue(E.N)
    case segueNotDismissable(E)
    case missingSegueForEdge(E)
    case ambiguousEgressEdges(Set<E>, from: E.N)
    case ambiguousIngressEdges(Set<E>, to: E.N)
    case missingEgressEdges(from: E.N)
    case missingIngressEdges(to: E.N)
}

extension HelmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .empty:
            return "The navigation graph is empty."
        case .missingInlets:
            return "The navigation graph has no inlets (no entry points). Check if the first segue you added is not part of a cycle. Cycles are allowed only as long as the navigation graph has at least one node that's not part of any cycles."
        case let .autoCycleDetected(segues):
            return "Auto segues cycle found: \(segues). This would lead to an infinite loop when each auto segue triggers the other."
        case let .ambiguousAutoSegues(segues):
            return "Ambiguous navigation. Multiple auto segues found: \(segues)."
        case let .missingTaggedSegue(name):
            return "Can't find segue with tag \(name)."
        case .ambiguousForwardInlets:
            return "Can't initially forward a navigation graph with multiple inlets."
        case let .fragmentNotPresented(fragment):
            return "(\(fragment)) is not presented."
        case let .fragmentMissingDismissableSegue(fragment):
            return "\(fragment) has no dismissable ingress segue."
        case .emptyPath:
            return "Navigation path is empty."
        case let .missingSegueForEdge(edge):
            return "Navigation graph doesn't contain \(edge)"
        case let .ambiguousEgressEdges(edges, node):
            return "Unable to solve ambiguity. (\(node) has multiple egress segues candidates: (\(edges))."
        case let .ambiguousIngressEdges(edges, node):
            return "Unable to solve ambiguity. (\(node) has multiple ingress segues candidates: (\(edges))."
        case let .missingEgressEdges(node):
            return "Missing egress segues from \(node)."
        case let .missingIngressEdges(node):
            return "Missing ingress segues towards \(node)."
        case let .segueNotDismissable(segue):
            return "\(segue) is not dismissable."
        case let .pathMismatch(path):
            return "\(path) does not match any valid path in the navigation graph."
        case .ambiguousInlets:
            return "The navigation graph should only have one entry point."
        case let .oneEdgeToManySegues(segues):
            return "Multiple segues (\(segues)) define the edge between the same nodes."
        }
    }
}
