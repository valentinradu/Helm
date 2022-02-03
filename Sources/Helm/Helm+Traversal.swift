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
        var visited: HelmPath = []

        var degree: Int = 0
        while true {
            let fragment = result[result.count - 1]
            if let nextEdge = path.filter({ $0.from == fragment }).last,
               let nextDegree = path.lastIndex(of: nextEdge),
               degree <= nextDegree
            {
                degree = nextDegree
                if visited.contains(nextEdge) {
                    break
                }
                visited.append(nextEdge)
                
                guard let segue = try? segue(for: nextEdge.edge) else {
                    break
                }

                if segue.style == .pass {
                    result.removeLast()
                }
                result.append(nextEdge.to)
            }
            else {
                break
            }
        }

        return result
    }

    func breakPath(pathEdge: PathEdge<N>) -> HelmPath {
        var pathCopy = path
        let ingressEdges = pathCopy.ingressEdges(for: pathEdge.to)
        let egressEdges = pathCopy.egressEdges(for: pathEdge.to)
        for edge in ingressEdges.union(egressEdges) {
            pathCopy.remove(edge)
        }

        let removables = pathCopy
            .disconnectedSubgraphs
            .filter {
                !$0.has(node: pathEdge.from)
            }
            .flatMap { $0 }

        pathCopy.subtract(removables)

        return pathCopy
    }
}
