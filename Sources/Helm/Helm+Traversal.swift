//
//  File.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Collections
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
                if let index = path.firstIndex(where: { $0.to == pathEdge.from }) {
                    let graphPath = trimmedGraphPath(from: path[index])

                    result = OrderedSet(result.filter {
                        graphPath.has(node: $0)
                    })
                }
                else {
                    result.remove(pathEdge.from)
                }
                result.append(pathEdge.to)
            }
        }

        return result
    }

    func trimmedGraphPath(from pathEdge: PathEdge<N>) -> Set<PathEdge<N>> {
        var pathGraph = Set(path)
        let ingressEdges = pathGraph.ingressEdges(for: pathEdge.to)
        let egressEdges = pathGraph.egressEdges(for: pathEdge.to)
        for edge in ingressEdges.union(egressEdges) {
            pathGraph.remove(edge)
        }

        let removables = pathGraph
            .disconnectedSubgraphs
            .filter {
                !$0.has(node: pathEdge.from)
            }
            .flatMap { $0 }

        pathGraph.subtract(removables)

        return pathGraph
    }
}
