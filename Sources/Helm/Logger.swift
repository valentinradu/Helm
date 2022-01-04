//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Foundation

public enum HelmError<N: Node>: Error {
    case inwardIsolated(node: N)
    case inwardAmbiguous(node: N, segues: Set<Segue<N>>)
    case forwardIsolated(node: N)
    case forwardAmbigous(node: N, segues: Set<Segue<N>>)
    case missingSegues(value: Set<Segue<N>>)
    case noContext(from: N)
    case multiInletFlow(from: Set<N>)
    case noInletFlow
    case circularRedirection(segue: Segue<N>)
    case multiAuto(node: N, segues: Set<Segue<N>>)
    case cantFindaSegueCounterpart(segue: Segue<N>)
    case nothingPresented
}

extension HelmError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .inwardIsolated(node):
            return "No segue connects \(node) to the rest of the navigation graph"
        case let .inwardAmbiguous(node, segues):
            return "Ambiguous inward path detected. All the following segues lead to \(node): \(segues)."
        case let .missingSegues(segues):
            return "Trying to edit \(segues) failed because the segues are missing. Check the navigation graph and make sure they are defined."
        case let .forwardIsolated(node):
            return "There's no segue that points forward from the last presented node (\(node))"
        case let .forwardAmbigous(node, segues):
            return "Multiple segues (\(segues) points forward from the last presented node (\(node))"
        case let .noContext(from):
            return "Trying to dismiss a context from \(from) when the none of the presented nodes have a .modal or .context segue trait."
        case let .multiInletFlow(from):
            return "This flow has multiple inlets: \(from)"
        case .noInletFlow:
            return "This flow has no inlets. This can happen when the flow is empty or when nodes reference each other in a circular manner."
        case let .circularRedirection(segue):
            return "Circular redirection detected. The redirection flow contains the segue that triggers it: \(segue)"
        case let .multiAuto(node, segues):
            return "Multiple auto segues originate from \(node): \(segues)."
        case let .cantFindaSegueCounterpart(node):
            return "Can't find a segue counterpart for \(node) and go back."
        case .nothingPresented:
            return "The navigation graph has no presented nodes."
        }
    }
}
