//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Collections
import Foundation

public enum HelmError<S: Section>: Error {
    case emptyNav
    case noNavInlets
    case autoCycleDetected(segues: OrderedSet<Segue<S>>)
    case multiAuto(segues: OrderedSet<Segue<S>>)
    case multiTag(segues: OrderedSet<Segue<S>>, tag: SegueTag)
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
            return "Ambiguous navigation. While multiple segues can have the same tag (\(tag)), they can't have the same in section while doing so: \(segues)."
        }
    }
}
