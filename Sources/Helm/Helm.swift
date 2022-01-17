//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Collections
import Foundation
import SwiftUI

// A helper for navigating using any of the navigation methods (present, dismiss or replace).
public enum EdgeTransition<N: Fragment>: Hashable {
    case present(edge: DirectedEdge<N>)
    case dismiss(edge: DirectedEdge<N>)
    case replace(path: OrderedSet<DirectedEdge<N>>)
}

/// `Helm` holds the navigation rules plus the path that leads to the currently presented fragments.
public class Helm<N: Fragment>: ObservableObject {
    public typealias HelmSegue = Segue<N>
    public typealias HelmGraph = Set<HelmSegue>
    public typealias HelmTransition = EdgeTransition<N>
    public typealias HelmEdge = DirectedEdge<N>
    public typealias HelmPath = OrderedSet<HelmEdge>
    public typealias HelmFragments = OrderedSet<N>
    private typealias ConcreteHelmError = HelmError<N>
    /// The navigation graph describes all the navigation rules in the app.
    public let nav: HelmGraph

    /// The path that leads to the currently presented fragments.
    public private(set) var path: HelmPath {
        didSet {
            presentedFragments = calculatePresentedFragments()
        }
    }

    /// The presented fragments.
    @Published public private(set) var presentedFragments: HelmFragments

    /// All the errors triggered by navigating the graph.
    @Published public private(set) var errors: [Swift.Error]

    private let edgeToSegueMap: [HelmEdge: HelmSegue]

    /// Initializes a new Helm instance.
    /// - parameter nav: A directed graph of segues that defies all the navigation rules in the app.
    /// - parameter path: The path that leads to the currently presented fragments.
    public init(nav: HelmGraph,
                path: HelmPath = []) throws
    {
        self.errors = []
        self.presentedFragments = []
        self.nav = nav
        self.edgeToSegueMap = nav
            .map {
                ($0.edge, $0)
            }
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        self.path = path

        try validate()

        self.presentedFragments = calculatePresentedFragments()
    }

    /// Presents a fragment.
    /// A segue must connect it to one of the presented fragment.
    /// If there is no such segue, the operation fails.
    /// If multiple presented origin fragments are available, the search starts with the lastest.
    /// - parameter fragment: The given fragment.
    public func present(fragment: N) {
        do {
            if path.isEmpty {
                let segue: HelmSegue
                do {
                    segue = try nav.inlets.uniqueIngressEdge(for: fragment)
                } catch {
                    throw ConcreteHelmError.missingSegueToFragment(fragment)
                }

                try present(edge: segue.edge)
            } else {
                let segues = presentedFragments
                    .reversed()
                    .flatMap {
                        nav.egressEdges(for: $0).ingressEdges(for: fragment)
                    }

                guard let segue = segues.first else {
                    throw ConcreteHelmError.missingSegueToFragment(fragment)
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
                throw ConcreteHelmError.missingTaggedSegue(name: AnyHashable(tag))
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
            let fragment = try presentedFragments.last.unwrap()
            let segue: HelmSegue
            do {
                segue = try nav.uniqueEgressEdge(for: fragment)
            } catch {
                throw ConcreteHelmError.ambiguousForwardFromFragment(fragment)
            }

            try present(edge: segue.edge)
        } catch {
            errors.append(error)
        }
    }

    /// Triggers a segue presenting its out node.
    /// If possible, use one of the higher level present or dismiss methods instead.
    public func present(edge: HelmEdge) throws {
        let segue = try segue(for: edge)

        guard presentedFragments.contains(segue.from) else {
            throw ConcreteHelmError.fragmentNotPresented(segue.from)
        }

        path.append(edge)

        if let autoSegue = nav
            .egressEdges(for: edge.to)
            .first(where: { $0.auto })
        {
            try present(edge: autoSegue.edge)
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

            guard let segue = segues.first else {
                throw ConcreteHelmError.fragmentMissingDismissableSegue(fragment)
            }

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
            guard let segue = try path
                .reversed()
                .map({ try segue(for: $0) })
                .first(where: { $0.tag == AnyHashable(tag) })
            else {
                throw ConcreteHelmError.missingTaggedSegue(name: AnyHashable(tag))
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
                throw ConcreteHelmError.emptyPath
            }

            try dismiss(edge: edge)
        } catch {
            errors.append(error)
        }
    }

    /// Triggers a segue dismissing its out node.
    /// If possible, use one of the higher level present or dismiss methods instead.
    public func dismiss(edge: HelmEdge) throws {
        guard let segue = nav.first(where: { $0.edge == edge }) else {
            throw ConcreteHelmError.missingSegueForEdge(edge)
        }

        guard segue.dismissable else {
            throw ConcreteHelmError.segueNotDismissable(segue)
        }

        guard path.contains(edge) else {
            throw ConcreteHelmError.missingPathEdge(segue)
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

    /// Replaces the entire current navigation path an re-validates it.
    /// - parameter path: The new path.
    /// - throws: Throws if the new path fails validation.
    public func replace(path: HelmPath) throws {
        self.path = path
        try validate()
    }

    /// Navigates a transition calling the right method (present, dismiss or replace),
    /// and advancing the navigation.
    /// - parameter transition: A transition.
    /// - throws: Throws if the transition is not valid.
    public func navigate(transition: HelmTransition) throws {
        switch transition {
        case let .present(edge):
            try present(edge: edge)
        case let .dismiss(edge):
            try dismiss(edge: edge)
        case let .replace(path):
            try replace(path: path)
        }
    }

    /// Checks if a fragment is presented. Shorthand for `presentedFragments.contains(fragment)`
    /// - returns: True if the fragment is presented.
    public func isPresented(_ fragment: N) -> Bool {
        return presentedFragments.contains(fragment)
    }

    /// The entry fragment in the navigation graph.
    /// The entry fragment is initially presented.
    public var entry: N {
        nav.inlets.map { $0.from }[0]
    }

    /// A special `isPresented(fragment:)` function that returns a binding.
    /// Setting the binding value to false is the same thing as calling `dismiss(fragment:)` with the fragment as the parameter.
    /// - parameter fragment: The fragment
    /// - returns: A binding, true if the fragment is presented.
    public func isPresented(_ fragment: N) -> Binding<Bool> {
        Binding {
            self.isPresented(fragment)
        }
        set: {
            if $0 {
                self.present(fragment: fragment)
            } else {
                self.dismiss(fragment: fragment)
            }
        }
    }

    /// A special `isPresented(fragment:)` function that takes multiple fragments and returns a binding with the one that's presented or nil otherwise.
    /// Setting the binding value to other fragment is the same thing as calling `present(fragment:)` with the fragment as the parameter. Setting the value to nil will dismiss all fragments.
    /// - parameter fragments: The query fragments
    /// - returns: The first presented fragment binding, nil if none are presented.
    public func pickPresented(_ fragments: Set<N>) -> Binding<N?> {
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

    /// Returns the segue with the given edge, if any.
    /// - parameter edge: The edge
    /// - throws: Throws if no segue can be found for the edge.
    public func segue(for edge: HelmEdge) throws -> HelmSegue {
        if let segue = edgeToSegueMap[edge] {
            return segue
        }
        throw ConcreteHelmError.missingSegueForEdge(edge)
    }

    /// Get all the possible transitions in the current navigation graph.
    /// This method does a deepth first search on the navigation graph while respecting all the navigation rules.
    public func transitions(from: N? = nil,
                            until: N? = nil) -> [HelmTransition]
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
            let transition = HelmTransition.present(edge: segue.edge)

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
                    (path.union([segue.edge]), $0)
                })
            } else {
                if let (nextPath, _) = stack.last {
                    result.append(.replace(path: nextPath))
                }
            }
        }

        return result
    }

    private func validate() throws {
        if nav.isEmpty {
            throw ConcreteHelmError.empty
        }

        if nav.inlets.count == 0 {
            throw ConcreteHelmError.missingInlets
        }

        guard Set(nav.inlets.map { $0.from }).count == 1 else {
            throw ConcreteHelmError.ambiguousInlets
        }

        var edgeToSegue: [HelmEdge: HelmSegue] = [:]

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

        guard path.isSubset(of: nav.map { $0.edge }) else {
            throw ConcreteHelmError.pathMismatch(Set(path))
        }
    }

    private func calculatePresentedFragments() -> HelmFragments {
        var result: HelmFragments = [entry]

        for edge in path {
            guard let segue = edgeToSegueMap[edge] else {
                return []
            }
            switch segue.rule {
            case .hold:
                result.append(segue.to)
            case .pass:
                result.remove(segue.from)
                result.append(segue.to)
            }
        }

        return result
    }
}
