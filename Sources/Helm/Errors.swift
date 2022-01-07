//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Foundation

public enum HelmError<S: Section>: Error {
    case emptyNav
    case noNavInlets
    case autoCycleDetected(segues: Set<Segue<S>>)
}

extension HelmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyNav:
            return "The nav graph has to have at least one segue."
        case .noNavInlets:
            return "The nav graph has no inlets. At least one node has to have no ingress segues."
        case let .autoCycleDetected(segues):
            return "We detected a cycle of auto segues: (\(segues)). This can freeze the app since each segue auto presents the next one."
        }
    }
}
