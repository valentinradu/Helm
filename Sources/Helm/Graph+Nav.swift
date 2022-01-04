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
    func present(node: N) {
//        guard segues.count > 0 else {
//            reportError("Failed to present \(node). No segue connects \(node) to the rest of the navigation graph")
//            return
//        }
//
//        guard segues.count == 1 else {
//            reportError("Failed to present \(node). The following segues lead to \(node): \(segues). Only ")
//            return
//        }
    }

    /// Activates a node flow.
    /// At least one node needs to be reachable (at least one segue must lead to it from the current active nodes)
    /// - parameter flow: The flow to navigate to
    /// - seealso: `present(node:)`
    func present(flow: Flow<N>) {}

    /// Looks at the most recently presented node and navigates any connected egress segue to a node that is not yet presented. Note that there might be multiple such nodes, or none, in which case `forward()` does nothing.
    func forward() {}

    /// Looks at the most recently presented node and navigates using the segue that points to the previously presented node. Note that there might be no such a segue, in which case `back()` does nothing.
    func back() {}

    /// Attempts to reach a node navigating using only reverse segues relative to the ones already presented.
    func back(to: N) {}

    /// Looks for the latest node that has a `.context` trait and deactivates it (and all the nodes originating from it) by following the reverse segue relative to the one that presented the node (if one is present).
    /// Used mostly for modals (where dismissing will close the modal, regardless of the navigation state) and master-detail lists, where dismissing will hide the details)
    func dismiss() {}

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
