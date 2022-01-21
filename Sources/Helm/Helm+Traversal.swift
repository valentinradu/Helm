//
//  File.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Foundation

public extension Helm {
    /// The navigation graph's entry point.
    /// The entry fragment is always initially presented.
    var entry: N {
        nav.inlets.map { $0.from }[0]
    }
}

extension Helm {
    func segue(for edge: HelmGraphEdge) throws -> HelmSegue {
        if let segue = edgeToSegueMap[edge] {
            return segue
        }
        throw ConcreteHelmError.missingSegueForEdge(edge)
    }

    func calculatePresentedFragments() -> HelmPathFragments {
        var result: HelmPathFragments = [PathFragment(entry)]

        for pathEdge in path {
            guard let segue = try? segue(for: pathEdge.edge) else {
                return []
            }
            switch segue.style {
            case .hold:
                result.append(pathEdge.to)
            case .pass:
                result.remove(pathEdge.from)
                result.append(pathEdge.to)
            }
        }

        return result
    }
}
