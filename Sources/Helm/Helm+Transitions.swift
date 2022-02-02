//
//  File.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Collections
import Foundation

public extension Helm {
    typealias PathFragmentIdentityProvider<ID: PathFragmentIdentifier> = (HelmGraphEdge) -> ID?

    /// Get all the possible transitions in the current navigation graph.
    /// - seealso: transitions(from:, identityProvider:)
    func transitions(from: N? = nil) -> [HelmTransition] {
        return transitions(from: from) { _ in
            String?.none
        }
    }

    /// Get all the possible transitions in the current navigation graph.
    /// This method does a deepth first search on the navigation graph while respecting all the navigation rules.
    /// - parameter from: The fragment to start at. If not provided whole graph is traversed.
    /// - parameter identityProvider: A provider that assigns ids to fragments as the graph is traversed.
    func transitions<ID>(from: N? = nil,
                         identityProvider: PathFragmentIdentityProvider<ID>?) -> [HelmTransition] where ID: PathFragmentIdentifier
    {
        var result: [HelmTransition] = []
        var visited: Set<HelmSegue> = []
        let inlets = OrderedSet(nav.egressEdges(for: from ?? entry).sorted())
        guard inlets.count > 0 else {
            return []
        }

        var stack: [(HelmPath, HelmSegue)] = inlets.map {
            ([], $0)
        }

        while stack.count > 0 {
            let (path, segue) = stack.removeLast()
            let pathEdge = PathEdge(segue.edge,
                                    id: identityProvider.flatMap { $0(segue.edge) })
            let transition = HelmTransition.present(pathEdge: pathEdge)

            result.append(transition)
            visited.insert(segue)

            let nextSegues = OrderedSet(
                nav
                    .egressEdges(for: segue.to)
                    .filter { !visited.contains($0) }
                    .sorted()
            )

            if nextSegues.count > 0 {
                stack.append(contentsOf: nextSegues.map {
                    let nextPathComponent = PathEdge<N>(segue.edge)
                    let nextPath = path + [nextPathComponent]
                    return (nextPath, $0)
                })
            } else {
                if let (nextPath, _) = stack.last {
                    result.append(.replace(path: nextPath))
                }
            }
        }

        return result
    }
}
