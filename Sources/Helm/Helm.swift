//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Collections
import Foundation
import SwiftUI

private extension Set {
    func presentedFragments<N: Fragment>(forPath path: OrderedSet<DirectedEdge<Element.N>>) -> OrderedSet<Element.N>
        where Element == Segue<N>
    {
        var result: OrderedSet<Element.N> = []

        for edge in path {
            guard let segue = first(where: { $0.edge == edge }) else {
                return []
            }
            switch segue.rule {
            case .hold:
                result.append(segue.to)
            case .replace:
                result.remove(segue.from)
                result.append(segue.to)
            }
        }

        return result
    }
}

/// `Helm` holds all navigation rules between fragments in the app, plus the path that leads to the currently presented ones.
public class Helm<N: Fragment>: ObservableObject {
    public typealias S = Segue<N>
    /// The graph that describes all the navigation rules in the app.
    public let nav: Set<S>

    /// The currently presented fragments and the relationship between them.
    public private(set) var path: OrderedSet<DirectedEdge<N>> {
        didSet {
            presentedFragments = nav.presentedFragments(forPath: path)
        }
    }

    /// The presented fragments in the order they were presented.
    @Published public private(set) var presentedFragments: OrderedSet<N>

    /// All the errors triggered by navigating
    @Published public private(set) var errors: [Error]

    /// Initializes a new Helm instance.
    /// - parameter nav: A directed graph of segues that defies all the navigation rules between fragments in the app.
    /// - parameter path: The path that leads to the currently presented fragments.
    public init(nav: Set<S>,
                path: OrderedSet<DirectedEdge<S.N>> = []) throws
    {
        self.errors = []
        self.presentedFragments = nav.presentedFragments(forPath: path)
        self.nav = nav
        self.path = path
        try validate()
    }

    /// Presents a fragment.
    /// A segue must connect it to one of the presented fragment.
    /// If there is no such segue, the operation fails.
    /// If multiple presented origin fragments are available, the search starts with the lastest.
    /// - parameter fragment: The given fragment.
    public func present(fragment: N) {
        do {
            if presentedFragments.isEmpty {
                let segue = try nav.inlets.uniqueIngressEdge(for: fragment)
                try present(edge: segue.edge)
            } else {
                let segues = presentedFragments
                    .reversed()
                    .flatMap {
                        nav.egressEdges(for: $0).ingressEdges(for: fragment)
                    }

                guard let segue = segues.first else {
                    throw HelmError<S>.missingEgressEdges(from: fragment)
                }

                try present(edge: segue.edge)
            }
        } catch {
            errors.append(error)
        }
    }

    /// Presents a fragment by triggering a segue with a specific tag.
    /// The segue must originate from a presented fragment.
    /// If there is no such segue, the operation fails.
    /// - parameter tag: The tag to look after.
    public func present<T: SegueTag>(tag: T) {
        do {
            let segues = presentedFragments
                .reversed()
                .flatMap {
                    nav
                        .egressEdges(for: $0)
                        .filter { $0.tag == AnyHashable(tag) }
                }

            guard let last = segues.last else {
                throw HelmError<S>.missingTaggedSegue(name: AnyHashable(tag))
            }

            try present(edge: last.edge)
        } catch {
            errors.append(error)
        }
    }

    /// Presents the next fragment by triggering the sole egress segue of the latest presented fragment.
    /// If the fragment has more than a segue, the operation fails
    /// If the fragment has no segue, the operation fails
    public func forward() {
        do {
            if let fragment = presentedFragments.last {
                let segue = try nav.uniqueEgressEdge(for: fragment)
                try present(edge: segue.edge)
            } else {
                let segues = nav.inlets

                guard segues.count == 1 else {
                    throw HelmError<S>.ambiguousForwardInlets
                }

                let segue = segues.first!
                try present(edge: segue.edge)
            }
        } catch {
            errors.append(error)
        }
    }

    /// Dismisses a fragment.
    /// If the fragment is not already presented, the operation fails.
    /// If the fragment has no dismissable ingress segues, the operation fails.
    /// - note: Only the segues in the path (already visited) are considered.
    /// - parameter fragment: The given fragment.
    public func dismiss(fragment: N) {
        do {
            let segues = presentedFragments
                .reversed()
                .flatMap {
                    nav
                        .ingressEdges(for: $0)
                        .filter { $0.dismissable }
                }

            guard segues.count > 0 else {
                throw HelmError<S>.fragmentMissingDismissableSegue(fragment)
            }

            let segue = segues.first!
            try dismiss(edge: segue.edge)
        } catch {
            errors.append(error)
        }
    }

    /// Dismisses a fragment by triggering in reverse a segue with a specific tag.
    /// If there is no such segue in the path (already visited), the operation fails.
    /// - parameter tag: The tag to look after.
    public func dismiss<T: SegueTag>(tag: T) {
        do {
            guard let segue = nav.first(where: { $0.tag == AnyHashable(tag) }) else {
                throw HelmError<S>.missingTaggedSegue(name: AnyHashable(tag))
            }

            try dismiss(edge: segue.edge)
        } catch {
            errors.append(error)
        }
    }

    /// Dismisses the last presented fragment.
    /// The operation fails if the fragment has no dismissable ingress segue.
    public func dismiss() {
        do {
            guard let edge = path.last else {
                throw HelmError<S>.emptyPath
            }

            try dismiss(edge: edge)
        } catch {
            errors.append(error)
        }
    }

    /// Triggers a segue presenting its out node.
    /// If possible, use one of the higher level present or dismiss methods instead.
    public func present(edge: DirectedEdge<S.N>) throws {
        guard let segue = nav.first(where: { $0.edge == edge }) else {
            throw HelmError.missingSegueForEdge(edge)
        }

        guard presentedFragments.contains(segue.from) else {
            throw HelmError<S>.fragmentNotPresented(segue.from)
        }

        path.append(edge)
    }

    /// Triggers a segue dismissing its out node.
    /// If possible, use one of the higher level present or dismiss methods instead.
    public func dismiss(edge: DirectedEdge<S.N>) throws {
        guard let segue = nav.first(where: { $0.edge == edge }) else {
            throw HelmError.missingSegueForEdge(edge)
        }

        guard segue.dismissable else {
            throw HelmError<S>.segueNotDismissable(segue)
        }

        guard path.contains(edge) else {
            throw HelmError<S>.fragmentNotPresented(segue.from)
        }

        for ingressSegue in path.ingressEdges(for: segue.to) {
            path.remove(ingressSegue)
        }

        let removables = path
            .disconnectedSubgraphs
            .filter {
                !$0.has(node: segue.from)
            }
            .flatMap { $0 }

        path = path.subtracting(removables)
    }

    /// Checks if a fragment is presented. Shorthand for `presentedFragments.contains(fragment)`
    /// - returns: True if the fragment is presented.
    public func isPresented(_ fragment: N) -> Bool {
        return presentedFragments.contains(fragment)
    }

    /// A special `isPresented(fragment:)` function that returns a binding.
    /// Setting the value to false from the binding is the same thing as calling `dismiss(fragment:)` with the fragment as the parameter
    /// - parameter fragment: The fragment
    /// - returns: A binding, true if the fragment is presented.
    public func isPresented(_ fragment: N) -> Binding<Bool> {
        return Binding {
            self.isPresented(fragment)
        } set: {
            if $0 {
                self.present(fragment: fragment)
            } else {
                self.dismiss(fragment: fragment)
            }
        }
    }

    private func validate() throws {
        if nav.isEmpty {
            throw HelmError<S>.empty
        }

        if nav.inlets.count == 0 {
            throw HelmError<S>.missingInlets
        }

        guard Set(nav.inlets.map { $0.from }).count == 1 else {
            throw HelmError<S>.ambiguousInlets
        }

        var edgeToSegue: [DirectedEdge<S.N>: S] = [:]

        for segue in nav {
            if let other = edgeToSegue[segue.edge] {
                throw HelmError.oneEdgeToManySegues([other, segue])
            }
            edgeToSegue[segue.edge] = segue
        }

        let autoSegues = Set(nav.filter { $0.auto })
        if autoSegues.hasCycle {
            throw HelmError.autoCycleDetected(autoSegues)
        }

        guard path.isSubset(of: nav.map { $0.edge }) else {
            throw HelmError.pathMismatch(Set(path))
        }
    }
}
