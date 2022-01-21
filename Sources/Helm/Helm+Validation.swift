//
//  File.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Foundation

extension Helm {
    func validate() throws {
        if nav.isEmpty {
            throw ConcreteHelmError.empty
        }

        if nav.inlets.count == 0 {
            throw ConcreteHelmError.missingInlets
        }

        guard Set(nav.inlets.map { $0.from }).count == 1 else {
            throw ConcreteHelmError.ambiguousInlets
        }

        var edgeToSegue: [HelmGraphEdge: HelmSegue] = [:]

        for segue in nav {
            if let other = edgeToSegue[segue.edge] {
                throw ConcreteHelmError.oneEdgeToManySegues([other, segue])
            }
            edgeToSegue[segue.edge] = segue
        }

        let autoSegues = Set(nav.filter { $0.auto })
        if autoSegues.hasCycle {
            throw ConcreteHelmError.autoCycleDetected(autoSegues)
        }

        guard Set(path.map(\.edge)).isSubset(of: nav.map { $0.edge }) else {
            throw ConcreteHelmError.pathMismatch(Set(path.map(\.edge)))
        }
    }
}
