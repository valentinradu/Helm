//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation
import SwiftUI

public extension NavigationGraph {
    /// Activates a node. If the segue that leads to it is not marked as `.cover`, all its the siblings will be deactivated.
    /// The node needs to be reachable (at least one segue must lead to it from the current active nodes)
    /// - parameter node: The node to navigate to
    func present(node: N) throws {
        var segues: Set<Segue<N>> = []
        if pathFlow.isEmpty {
            for segue in navFlow.inlets {
                if segue.out == node {
                    segues.insert(segue)
                }
            }
        }
        else {
            for segue in navFlow.substract(flow: pathFlow).inlets {
                if segue.out == node {
                    segues.insert(segue)
                }
            }
        }
        
        pathFlow = pathFlow.add(segue: segues.first!)
    }

    /// Activates a node flow.
    /// At least one node needs to be reachable (at least one segue must lead to it from the current active nodes)
    /// - parameter flow: The flow to navigate to
    /// - seealso: `present(node:)`
    func present(flow: Flow<N>) throws {
        for segue in flow.segues {
            if segue == flow.segues.first {
                try present(node: segue.in)
            }
            try present(node: segue.out)
        }
    }

    /// Looks at the most recently presented segue and tries to navigate any egress segue from its `out` node to a node that is not yet presented. Note that there might be multiple such segues, or none, in which case `forward()` does nothing.
    func forward() throws {
        var segues: Set<Segue<N>> = []
        if let last = pathFlow.segues.last {
            segues = navFlow.egressSegues(for: last.out)
            
            guard segues.count > 0 else {
                throw HelmError.inwardIsolated(node: last.out)
            }

            guard segues.count == 1 else {
                throw HelmError.inwardAmbiguous(node: last.out, segues: segues)
            }
            
            pathFlow = try pathFlow.add(segue: segues.first.unwrap())
        }
        else {
            
        }
    }

    /// Looks at the most recently presented segue and tries to navigate using counterpart. Note that there might be no such a segue counterpart, in which case `back()` does nothing.
    func back() throws {}

    /// Attempts to reach a node navigating using only reverse segues relative to the ones already presented.
    func back(to: N) throws {}

    /// Looks for the latest node that has a `.context` trait and deactivates it (and all the nodes originating from it) by following the reverse segue relative to the one that presented the node (if one is present).
    /// Used mostly for modals (where dismissing will close the modal, regardless of the navigation state) and master-detail lists, where dismissing will hide the details)
    func dismiss() throws {}

    /// Checks if a node is presented (active)
    /// - returns: True if the node is active
    func isPresented(_ node: N) -> Bool {
        return true
    }

    /// A special `isPresented(node:)` function that returns a binding.
    /// When the value is set to false from the binding, the node becomes inactive, trimming all the nodes that originate from it as well.
    func isPresented(_ node: N) -> Binding<Bool> {
        return .constant(true)
    }
}
