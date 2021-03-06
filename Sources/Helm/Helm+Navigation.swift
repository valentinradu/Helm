//
//  File.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Foundation
import OrderedCollections
import SwiftUI

// Present-related methods
public extension Helm {
    /// Presents a fragment.
    /// - seealso: `present(fragment:, id:)`
    func present(fragment: N) {
        do {
            let pathEdge = try presentablePathEdge(for: fragment,
                                                   id: AnyHashable?.none)
            try present(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Presents a fragment.
    /// An ingress segue must connect the fragment to one of the already presented fragments.
    /// If there is no such segue, the operation fails.
    /// If multiple presented origin fragments are available, the search starts with the latest in the path.
    /// - parameter fragment: The given fragment.
    /// - parameter id: An optional id to distinguish between same fragments displaying different data.
    func present<ID>(fragment: N, id: ID? = nil) where ID: PathFragmentIdentifier {
        do {
            let pathEdge = try presentablePathEdge(for: fragment, id: id)
            try present(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Presents a tag.
    /// - seealso: `present(tag:, id:)`
    func present<T>(tag: T) where T: SegueTag {
        do {
            let pathEdge = try presentablePathEdge(with: tag,
                                                   id: AnyHashable?.none)
            try present(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Presents a fragment by triggering a segue with a specific tag.
    /// The segue must originate from a presented fragment.
    /// If there is no such segue, the operation fails.
    /// - parameter tag: The tag to look after.
    /// - parameter id: An optional id to distinguish between same fragments displaying different data.
    func present<T, ID>(tag: T, id: ID?) where ID: PathFragmentIdentifier, T: SegueTag {
        do {
            let pathEdge = try presentablePathEdge(with: tag, id: id)
            try present(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Forwards navigation to the next fragment.
    /// - seealso: `forward(id:)`
    func forward() {
        do {
            let pathEdge = try presentableForwardPathEdge(id: AnyHashable?.none)
            try present(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Presents the next fragment by triggering the sole egress segue of the latest fragment in the path.
    /// If the fragment has more than a segue, the operation fails
    /// If the fragment has no segue, the operation fails
    /// - parameter id: An optional id to distinguish between same fragments displaying different data.
    func forward<ID>(id: ID?) where ID: PathFragmentIdentifier {
        do {
            let pathEdge = try presentableForwardPathEdge(id: id)
            try present(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Checks if a fragment can be presented
    /// - parameter fragment: The fragment
    func canPresent(fragment: N) -> Bool {
        do {
            _ = try presentablePathEdge(for: fragment,
                                        id: AnyHashable?.none)
            return true
        } catch {
            return false
        }
    }

    /// Checks if a tag can be presented
    /// - parameter tag: The tag
    func canPresent<T>(using tag: T) -> Bool where T: SegueTag {
        do {
            _ = try presentablePathEdge(with: tag,
                                        id: AnyHashable?.none)
            return true
        } catch {
            return false
        }
    }

    /// Checks if a fragment is presented.
    /// - seealso: isPresented(fragment:, id:)
    func isPresented(_ fragment: N) -> Bool {
        return isPresented(fragment, id: String?.none)
    }

    /// Checks if a fragment with a specific id is presented.
    /// - returns: True if the fragment is presented.
    func isPresented<ID>(_ fragment: N, id: ID?) -> Bool where ID: PathFragmentIdentifier {
        return presentedFragments
            .contains(PathFragment(fragment, id: id))
    }

    /// Matches all the ids of a specific fragment
    /// - returns: The set of ids
    func matchAll<ID>(_ fragment: N) -> Set<ID> where ID: PathFragmentIdentifier {
        Set(presentedFragments
            .filter { $0.wrappedValue == fragment }
            .compactMap {
                $0.id?.base as? ID
            })
    }

    /// Matches the first presented id
    /// - returns: The fragment id, if a match was found
    /// - warning: If none or multiple (with different ids) fragments are presented this function returns nil
    func matchFirst<ID>(_ fragment: N) -> ID? where ID: PathFragmentIdentifier {
        let allIds: Set<ID> = matchAll(fragment)
        guard allIds.count == 1 else {
            return nil
        }
        return allIds.first!
    }

    /// A special `isPresented(fragment:)` function that takes multiple fragments and returns a binding with the one that's presented or nil otherwise.
    /// Setting the binding value to other fragment is the same thing as calling `present(fragment:)` with the fragment as the parameter. Setting the value to nil will dismiss all fragments.
    /// - parameter fragments: The query fragments
    /// - returns: The first presented fragment binding, nil if none are presented.
    func pickPresented(_ fragments: Set<N>) -> Binding<N?> {
        return Binding {
            fragments.first(where: { self.isPresented($0) })
        }
        set: {
            if let fragment = $0 {
                self.present(fragment: fragment)
            } else {
                for fragment in fragments {
                    if self.isPresented(fragment) {
                        self.dismiss(fragment: fragment)
                    }
                }
            }
        }
    }

    /// A special `isPresented(fragment:)` function that returns a binding.
    /// - see also `isPresented(fragment:, id:)`
    func isPresented(_ fragment: N) -> Binding<Bool> {
        isPresented(fragment, id: String?.none)
    }

    /// A special `isPresented(fragment:)` function that returns a binding.
    /// Setting the binding value to false is the same thing as calling `dismiss(fragment:)` with the fragment as the parameter.
    /// - parameter fragment: The fragment
    /// - returns: A binding, true if the fragment is presented.
    func isPresented<ID>(_ fragment: N, id: ID?) -> Binding<Bool> where ID: PathFragmentIdentifier {
        Binding {
            self.isPresented(fragment, id: id)
        }
        set: { [self] in
            if $0 {
                if !isPresented(fragment, id: id) {
                    present(fragment: fragment, id: id)
                }
            } else {
                if isPresented(fragment, id: id) {
                    dismiss(fragment: fragment)
                }
            }
        }
    }
}

// Present-related private methods
extension Helm {
    func present(pathEdge: PathEdge<N>) throws {
        path = OrderedSet(path.prefix(while: { pathEdge != $0 }))
        path.append(pathEdge)

        if let pathEdge = try autoPresentablePathEdge(from: pathEdge.to.wrappedValue) {
            try present(pathEdge: pathEdge)
        }
    }

    func presentablePathEdge<ID>(for fragment: N, id: ID? = nil) throws -> PathEdge<N> where ID: PathFragmentIdentifier {
        if path.isEmpty {
            do {
                let segue = try nav.inlets.uniqueIngressEdge(for: fragment)
                return PathEdge(segue.edge,
                                sourceId: nil,
                                targetId: id)
            } catch {
                throw ConcreteHelmError.missingSegueToFragment(fragment)
            }
        } else {
            let pathEdges = presentedFragments
                .reversed()
                .flatMap { edge in
                    nav
                        .egressEdges(for: edge.wrappedValue)
                        .ingressEdges(for: fragment)
                        .map {
                            PathEdge($0.edge,
                                     sourceId: edge.id,
                                     targetId: id)
                        }
                }

            guard let pathEdge = pathEdges.first else {
                throw ConcreteHelmError.missingSegueToFragment(fragment)
            }

            return pathEdge
        }
    }

    func presentablePathEdge<T, ID>(with tag: T, id: ID? = nil) throws -> PathEdge<N> where T: SegueTag, ID: PathFragmentIdentifier {
        let pathEdges = presentedFragments
            .reversed()
            .flatMap { edge in
                nav
                    .egressEdges(for: edge.wrappedValue)
                    .filter { $0.tag == AnyHashable(tag) }
                    .map {
                        PathEdge($0.edge,
                                 sourceId: edge.id,
                                 targetId: id)
                    }
            }

        guard let pathEdge = pathEdges.last else {
            throw ConcreteHelmError.missingTaggedSegue(name: AnyHashable(tag))
        }

        return pathEdge
    }

    func presentableForwardPathEdge<ID>(id: ID? = nil) throws -> PathEdge<N>
        where ID: PathFragmentIdentifier
    {
        let fragment = try presentedFragments.last.unwrap()
        do {
            let segue = try nav.uniqueEgressEdge(for: fragment.wrappedValue)
            return PathEdge(segue.edge,
                            sourceId: fragment.id,
                            targetId: id)
        } catch {
            throw ConcreteHelmError.ambiguousForwardFromFragment(fragment.wrappedValue)
        }
    }

    func autoPresentablePathEdge(from fragment: N) throws -> PathEdge<N>? {
        if path.isEmpty {
            return nav
                .egressEdges(for: fragment)
                .filter { $0.auto }
                .first
                .map {
                    PathEdge($0.edge,
                             sourceId: AnyHashable?.none,
                             targetId: AnyHashable?.none)
                }
        } else {
            guard let pathEdge = presentedFragments
                .reversed()
                .compactMap({ edge in
                    nav
                        .egressEdges(for: fragment)
                        .first(where: { $0.auto })
                        .map {
                            PathEdge($0.edge,
                                     sourceId: edge.id,
                                     targetId: nil)
                        }
                })
                .last
            else {
                return nil
            }
            return pathEdge
        }
    }
}

// Dismiss-related methods
public extension Helm {
    /// Dismisses a fragment.
    /// If the fragment is not already presented, the operation fails.
    /// If the fragment has no dismissable ingress segues, the operation fails.
    /// - note: Only the segues in the path (already visited) are considered when searching for the dismissable ingress segue.
    /// - parameter fragment: The given fragment.
    func dismiss(fragment: N) {
        do {
            let pathEdge = try dismissablePathEdge(for: fragment)
            try dismiss(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Dismisses a fragment by triggering (in reverse) a segue with a specific tag.
    /// If there is no such segue in the path (already visited) or the segue is not dismissable, the operation fails.
    /// - parameter tag: The tag to look after.
    func dismiss<T>(tag: T) where T: SegueTag {
        do {
            let pathEdge = try dismissablePathEdge(with: tag)
            try dismiss(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Dismisses the last presented fragment.
    /// The operation fails if the latest fragment in the path has no dismissable ingress segue.
    func dismiss() {
        do {
            let pathEdge = try dismissableBackwardPathEdge()
            try dismiss(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Checks if a fragment can be dismissed.
    /// - parameter fragment: The fragment
    func canDismiss(fragment: N) -> Bool {
        do {
            _ = try dismissablePathEdge(for: fragment)
            return true
        } catch {
            return false
        }
    }

    /// Checks if a tag can be dismissed.
    /// - parameter tag: The tag
    func canDismiss<T>(using tag: T) -> Bool where T: SegueTag {
        do {
            _ = try dismissablePathEdge(with: tag)
            return true
        } catch {
            return false
        }
    }

    /// Checks if the last presented fragment can be dismissed.
    func canDismiss() -> Bool {
        do {
            _ = try dismissableBackwardPathEdge()
            return true
        } catch {
            return false
        }
    }

    /// Replaces the entire current presented path an re-validates it.
    /// - parameter path: The new path.
    /// - throws: Throws if the new path fails validation.
    func replace(path: HelmPath) throws {
        self.path = path
        try validate()
    }

    /// Navigates a transition calling the right method (present, dismiss or replace).
    /// - parameter transition: A transition.
    /// - throws: Throws if the transition is not valid.
    func navigate(transition: HelmTransition) throws {
        switch transition {
        case let .present(step):
            try present(pathEdge: step)
        case let .dismiss(step):
            try dismiss(pathEdge: step)
        case let .replace(path):
            try replace(path: path)
        }
    }
}

// Dismiss-related private methods
extension Helm {
    func dismiss(pathEdge: PathEdge<N>) throws {
        try isDismissable(pathEdge: pathEdge)
        path = breakPath(pathEdge: pathEdge)
    }

    func dismissablePathEdge(for fragment: N) throws -> PathEdge<N> {
        let segues = nav
            .ingressEdges(for: fragment)
            .filter { $0.dismissable }

        guard let pathEdge = path
            .reversed()
            .first(where: { segues.map(\.edge).contains($0.edge) })
        else {
            throw ConcreteHelmError.fragmentMissingDismissableSegue(fragment)
        }

        try isDismissable(pathEdge: pathEdge)

        return pathEdge
    }

    func dismissablePathEdge<T>(with tag: T) throws -> PathEdge<N> where T: SegueTag {
        let segues = nav.filter { $0.tag == AnyHashable(tag) }

        guard let pathEdge = path.reversed().first(where: { segues.map(\.edge).contains($0.edge) })
        else {
            throw ConcreteHelmError.missingTaggedSegue(name: AnyHashable(tag))
        }

        try isDismissable(pathEdge: pathEdge)

        return pathEdge
    }

    func dismissableBackwardPathEdge() throws -> PathEdge<N> {
        guard path.count > 0 else {
            throw ConcreteHelmError.emptyPath
        }

        for pathEdge in path.reversed() {
            do {
                try isDismissable(pathEdge: pathEdge)

                return pathEdge
            } catch ConcreteHelmError.segueNotDismissable {}
        }

        throw ConcreteHelmError.noDismissableSegues
    }

    func isDismissable(pathEdge: PathEdge<N>) throws {
        guard let segue = try? segue(for: pathEdge.edge) else {
            throw ConcreteHelmError.missingSegueForEdge(pathEdge.edge)
        }

        guard segue.dismissable else {
            throw ConcreteHelmError.segueNotDismissable(segue)
        }

        guard path.contains(pathEdge) else {
            throw ConcreteHelmError.missingPathEdge(segue)
        }
    }
}
