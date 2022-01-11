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
    case ambiguousForwardInlets
    case autoCycleDetected(Set<E>)
    case ambiguousAutoSegues(Set<E>)
    case missingTaggedSegue(name: AnyHashable)
    case sectionNotPresented(E.N)
    case sectionMissingDismissableSegue(E.N)
    case segueNotDismissable(E)
    case missingSegue(E)
    case ambiguousEgressEdges(Set<E>, from: E.N)
    case ambiguousIngressEdges(Set<E>, from: E.N)
    case missingEgressEdges(from: E.N)
    case missingIngressEdges(from: E.N)
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
        case let .sectionNotPresented(section):
            return "(\(section)) is not presented."
        case let .sectionMissingDismissableSegue(section):
            return "\(section) has no dismissable ingress segue."
        case .emptyPath:
            return "Navigation path is empty."
        case let .missingSegue(segue):
            return "Navigation graph doesn't contain \(segue)"
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
        }
    }
}
