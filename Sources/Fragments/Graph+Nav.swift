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
    func present(node: N) {}

    /// Activates a node flow.
    /// At least one node needs to be reachable (at least one segue must lead to it from the current active nodes)
    /// - parameter flow: The flow to navigate to
    /// - seealso: `present(node:)`
    func present(flow: Flow<N>) {}

    /// Looks at the most recently presented node and navigates any connected segue that has the `.next` trait, if any.
    /// Used mostly for chained navigation like tutorials and onboarding screens.
    func next() {}

    /// Looks at the most recently presented node and navigates any connected segue that has the `.prev` trait, if any.
    /// Used mostly for chained navigation like tutorials and onboarding screens.
    func prev() {}

    /// Looks for the latest node that has a `.conext` trait segue comming in and deactivates it (and all the nodes that originate from it)
    /// Used mostly for modals (where dismissing will close the modal, regardless of the navigation state) and master-detail lists, where dismissing will hide the details)
    func dismiss() {}

    /// Checks if a node is presented (active)
    /// - returns: True if the node is active
    func isPresented(_ node: N) -> Bool {
        return true
    }

    /// A special `isPresented(node:)` function that returns a binding.
    /// When the value is set to false from the binding, the node gets dismissed if it's a context, or simply deactivated if not.
    func isPresented(_ node: N) -> Binding<Bool> {
        return .constant(true)
    }
}
