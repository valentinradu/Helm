//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Collections
import Foundation

public enum HelmError: Error {
    case emptyNav
    case noNavInlets
    case autoCycleDetected(segues: CustomDebugStringConvertible)
    case multiAuto(segues: CustomDebugStringConvertible)
    case multiTag(segues: CustomDebugStringConvertible,
                  tag: CustomDebugStringConvertible)
    case missingTag(name: CustomDebugStringConvertible)
    case ambiguousForward(section: CustomDebugStringConvertible,
                          segues: CustomDebugStringConvertible)
    case missingForward(section: CustomDebugStringConvertible)
    case ambiguousForwardInlets
    case dismissingUnpresented(section: CustomDebugStringConvertible)
    case noDismissableSegue(section: CustomDebugStringConvertible)
    case cantDimissEmptyPath
}

public enum GraphError: Error {
    case ambiguousEgress(node: CustomDebugStringConvertible,
                         segues: CustomDebugStringConvertible)
    case ambiguousIngress(node: CustomDebugStringConvertible,
                          segues: CustomDebugStringConvertible)
    case missingEgress(node: CustomDebugStringConvertible)
    case missingIngress(node: CustomDebugStringConvertible)
}

extension HelmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyNav:
            return "The nav graph has to have at least one segue."
        case .noNavInlets:
            return "The nav graph has no inlets. At least one node has to have no ingress segues."
        case let .autoCycleDetected(segues):
            return "Auto segues cycle found: \(segues). This would lead to an infinite loop when each auto segue triggers the other."
        case let .multiAuto(segues):
            return "Ambiguous navigation. Multiple auto segues found: \(segues)."
        case let .multiTag(segues, tag):
            return "Ambiguous navigation. While multiple segues can have the same tag (\(tag)), they can't originate from the same section while doing so: \(segues)."
        case let .missingTag(name):
            return "Can't find segue with tag \(name)."
        case let .ambiguousForward(section, segues):
            return "Can't forward a section (\(section)) with multiple egress segue: \(segues)."
        case let .missingForward(section):
            return "Can't forward a section (\(section)) with no egress segue."
        case .ambiguousForwardInlets:
            return "Can't forward a nav graph with multiple inlets."
        case let .dismissingUnpresented(section):
            return "Attempting to dismiss a section (\(section)) that's not currently presented."
        case let .noDismissableSegue(section):
            return "\(section) has no dismissable segue."
        case .cantDimissEmptyPath:
            return "Can't dismiss any section because there are no presented sections."
        }
    }
}

extension GraphError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .ambiguousEgress(node, segues):
            return "Unable to solve ambiguity. (\(node) has multiple egress segues candidates: (\(segues))."
        case let .ambiguousIngress(node, segues):
            return "Unable to solve ambiguity. (\(node) has multiple ingress segues candidates: (\(segues))."
        case let .missingEgress(node):
            return "Missing egress segues from \(node)."
        case let .missingIngress(node):
            return "Missing ingress segues towards \(node)."
        }
    }
}
