//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Foundation

public enum HelmError<N: Fragment>: Equatable, Error {
    case empty
    case emptyPath
    case missingInlets
    case ambiguousInlets
    case oneEdgeToManySegues(Set<Segue<N>>)
    case autoCycleDetected(Set<Segue<N>>)
    case pathMismatch(Set<DirectedEdge<N>>)
    case ambiguousAutoSegues(Set<Segue<N>>)
    case missingSegueToFragment(N)
    case missingSegueForEdge(DirectedEdge<N>)
    case missingTaggedSegue(name: AnyHashable)
    case missingPathEdge(Segue<N>)
    case fragmentNotPresented(N)
    case ambiguousForwardFromFragment(N)
    case fragmentMissingDismissableSegue(N)
    case segueNotDismissable(Segue<N>)
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
        case let .fragmentNotPresented(fragment):
            return "(\(fragment)) is not presented."
        case let .fragmentMissingDismissableSegue(fragment):
            return "\(fragment) has no dismissable ingress segue."
        case .emptyPath:
            return "Navigation path is empty."
        case let .segueNotDismissable(segue):
            return "\(segue) is not dismissable."
        case let .pathMismatch(path):
            return "\(path) does not match any valid path in the navigation graph."
        case .ambiguousInlets:
            return "The navigation graph should only have one entry point."
        case let .ambiguousForwardFromFragment(fragment):
            return "Ambiguous forward navigation. Multiple segues leave \(fragment)"
        case let .oneEdgeToManySegues(segues):
            return "Multiple segues (\(segues)) for the same edge."
        case let .missingPathEdge(edge):
            return "\(edge) is missing from the path."
        case let .missingSegueForEdge(edge):
            return "No segue found for \(edge)"
        case let .missingSegueToFragment(fragment):
            return "No segue from a presented fragment to \(fragment)"
        }
    }
}

public enum DirectedEdgeCollectionError<E: DirectedConnectable>: Equatable, Error {
    case ambiguousEgressEdges(Set<E>, from: E.N)
    case ambiguousIngressEdges(Set<E>, to: E.N)
    case missingEgressEdges(from: E.N)
    case missingIngressEdges(to: E.N)
}

extension DirectedEdgeCollectionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .ambiguousEgressEdges(edges, node):
            return "Unable to solve ambiguity. (\(node) has multiple egress edges candidates: (\(edges))."
        case let .ambiguousIngressEdges(edges, node):
            return "Unable to solve ambiguity. (\(node) has multiple ingress edges candidates: (\(edges))."
        case let .missingEgressEdges(node):
            return "Missing egress edges from \(node)."
        case let .missingIngressEdges(node):
            return "Missing ingress edges towards \(node)."
        }
    }
}
