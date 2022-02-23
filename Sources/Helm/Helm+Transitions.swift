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
        var visited: Set<PathEdge<N>> = []
        let inlets = OrderedSet(
            nav
                .egressEdges(for: from ?? entry)
                .sorted()
                .map { segue in
                    PathEdge(segue.edge,
                             sourceId: nil,
                             targetId: identityProvider.flatMap { $0(segue.edge) })
                }
        )
        guard inlets.count > 0 else {
            return []
        }

        var stack: [(HelmPath, PathEdge<N>)] = inlets.map {
            ([], $0)
        }

        while stack.count > 0 {
            let (path, pathEdge) = stack.removeLast()
            let transition = HelmTransition.present(pathEdge: pathEdge)

            result.append(transition)
            visited.insert(pathEdge)

            let nextEdges = OrderedSet(
                nav
                    .egressEdges(for: pathEdge.to.wrappedValue)
                    .map { segue in
                        PathEdge<N>(segue.edge,
                                    sourceId: pathEdge.to.id,
                                    targetId: identityProvider.flatMap { $0(segue.edge) })
                    }
                    .filter { !visited.contains($0) }
                    .sorted()
            )

            if nextEdges.count > 0 {
                stack.append(contentsOf: nextEdges.map {
                    let nextPath = path.union([pathEdge])
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
