//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Collections
import Foundation
import SwiftUI

/// A helper listing all the navigation methods.
public enum PathTransition<N: Fragment>: Hashable {
    case present(pathEdge: PathEdge<N>)
    case dismiss(pathEdge: PathEdge<N>)
    case replace(path: OrderedSet<PathEdge<N>>)
}

public protocol PathFragmentIdentifier: Hashable {}
extension String: PathFragmentIdentifier {}
extension Int: PathFragmentIdentifier {}
extension AnyHashable: PathFragmentIdentifier {}

/// An edge between fragments in a path.
public struct PathEdge<N: Fragment>: Hashable, DirectedConnector {
    /// The input fragment
    public let from: PathFragment<N>
    /// The output fragment
    public let to: PathFragment<N>

    /// Init using a regular edge.
    public init(_ edge: DirectedEdge<N>) {
        from = PathFragment(edge.from)
        to = PathFragment(edge.to)
    }

    /// Init using a regular edge and an id for the destination fragment.
    public init<ID>(_ edge: DirectedEdge<N>, id: ID? = nil)
        where ID: PathFragmentIdentifier
    {
        from = PathFragment(edge.from)
        to = PathFragment(edge.to, id: id)
    }

    /// Turns the path edge into a regular edge.
    public var edge: DirectedEdge<N> {
        DirectedEdge(from: from.wrappedValue,
                     to: to.wrappedValue)
    }
}

public struct PathFragment<N: Fragment>: Fragment {
    public let wrappedValue: N
    public let id: AnyHashable?

    public init(_ fragment: N) {
        wrappedValue = fragment
        id = nil
    }

    public init<ID>(_ fragment: N, id: ID? = nil)
        where ID: PathFragmentIdentifier
    {
        wrappedValue = fragment
        self.id = id
    }

    public static func < (lhs: PathFragment<N>, rhs: PathFragment<N>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }
}

/// The main class. Holds the navigation rules plus the presented path.
/// Has methods to navigate and list all possible transitions, among others.
public class Helm<N: Fragment>: ObservableObject {
    public typealias HelmSegue = Segue<N>
    public typealias HelmGraph = Set<HelmSegue>
    public typealias HelmGraphEdge = DirectedEdge<N>
    public typealias HelmTransition = PathTransition<N>
    public typealias HelmPath = OrderedSet<PathEdge<N>>
    public typealias HelmPathFragments = OrderedSet<PathFragment<N>>
    private typealias ConcreteHelmError = HelmError<N>

    /// The navigation graph describes all the navigation rules.
    public let nav: HelmGraph

    /// The presented path. It leads to the currently presented fragments.
    public private(set) var path: HelmPath {
        didSet {
            presentedFragments = calculatePresentedFragments()
        }
    }

    /// The presented fragments.
    @Published private(set) var presentedFragments: HelmPathFragments

    /// All the errors triggered when navigating the graph.
    @Published public private(set) var errors: [Swift.Error]

    private let edgeToSegueMap: [HelmGraphEdge: HelmSegue]

    /// Initializes a new Helm instance.
    /// - parameter nav: A directed graph of segues that defines all the navigation rules in the app.
    /// - parameter path: The path that leads to the currently presented fragments.
    public init(nav: HelmGraph,
                path: HelmPath = []) throws
    {
        errors = []
        presentedFragments = []
        self.nav = nav
        edgeToSegueMap = nav
            .map {
                ($0.edge, $0)
            }
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        self.path = path

        try validate()

        presentedFragments = calculatePresentedFragments()
    }

    public func present(fragment: N) {
        do {
            let segue = try presentableSegue(for: fragment)
            try present(pathEdge: PathEdge(segue.edge))
        } catch {
            errors.append(error)
        }
    }

    /// Presents a fragment.
    /// An ingress segue must connect the fragment to one of the already presented fragments.
    /// If there is no such segue, the operation fails.
    /// If multiple presented origin fragments are available, the search starts with the latest in the path.
    /// - parameter fragment: The given fragment.
    public func present<ID>(fragment: N, id: ID? = nil) where ID: PathFragmentIdentifier {
        do {
            let segue = try presentableSegue(for: fragment)
            try present(pathEdge: PathEdge(segue.edge, id: id))
        } catch {
            errors.append(error)
        }
    }

    public func present<T>(tag: T) where T: SegueTag {
        do {
            let segue = try presentableSegue(with: tag)
            try present(pathEdge: PathEdge(segue.edge))
        } catch {
            errors.append(error)
        }
    }

    /// Presents a fragment by triggering a segue with a specific tag.
    /// The segue must originate from a presented fragment.
    /// If there is no such segue, the operation fails.
    /// - parameter tag: The tag to look after.
    public func present<T, ID>(tag: T, id: ID?) where ID: PathFragmentIdentifier, T: SegueTag {
        do {
            let segue = try presentableSegue(with: tag)
            try present(pathEdge: PathEdge(segue.edge, id: id))
        } catch {
            errors.append(error)
        }
    }

    public func forward() {
        do {
            let segue = try presentableForwardSegue()
            try present(pathEdge: PathEdge(segue.edge))
        } catch {
            errors.append(error)
        }
    }

    /// Presents the next fragment by triggering the sole egress segue of the latest fragment in the path.
    /// If the fragment has more than a segue, the operation fails
    /// If the fragment has no segue, the operation fails
    public func forward<ID>(id: ID?) where ID: PathFragmentIdentifier {
        do {
            let segue = try presentableForwardSegue()
            try present(pathEdge: PathEdge(segue.edge, id: id))
        } catch {
            errors.append(error)
        }
    }

    public func present(pathEdge: PathEdge<N>) throws {
        _ = try segue(for: pathEdge.edge)
        try isPresentable(fragment: pathEdge.from.wrappedValue)

        path.append(pathEdge)

        if let autoSegue = nav
            .egressEdges(for: pathEdge.to.wrappedValue)
            .first(where: { $0.auto })
        {
            try present(pathEdge: PathEdge(autoSegue.edge))
        }
    }

    public func isPresentable(fragment: N) throws {
        if !presentedFragments
            .map(\.wrappedValue)
            .contains(fragment)
        {
            throw ConcreteHelmError.fragmentNotPresented(fragment)
        }
    }

    public func canPresent(fragment: N) -> Bool {
        do {
            _ = try presentableSegue(for: fragment)
            try isPresentable(fragment: fragment)
            return true
        } catch {
            return false
        }
    }

    public func canPresent<T>(using tag: T) -> Bool where T: SegueTag {
        do {
            let segue = try presentableSegue(with: tag)
            try isPresentable(fragment: segue.to)
            return true
        } catch {
            return false
        }
    }

    public func presentableSegue(for fragment: N) throws -> HelmSegue {
        if path.isEmpty {
            do {
                return try nav.inlets.uniqueIngressEdge(for: fragment)
            } catch {
                throw ConcreteHelmError.missingSegueToFragment(fragment)
            }
        } else {
            let segues = presentedFragments
                .reversed()
                .flatMap {
                    nav
                        .egressEdges(for: $0.wrappedValue)
                        .ingressEdges(for: fragment)
                }

            guard let segue = segues.first else {
                throw ConcreteHelmError.missingSegueToFragment(fragment)
            }

            return segue
        }
    }

    public func presentableSegue<T>(with tag: T) throws -> HelmSegue where T: SegueTag {
        let segues = presentedFragments
            .reversed()
            .flatMap {
                nav
                    .egressEdges(for: $0.wrappedValue)
                    .filter { $0.tag == AnyHashable(tag) }
            }

        guard let segue = segues.last else {
            throw ConcreteHelmError.missingTaggedSegue(name: AnyHashable(tag))
        }

        return segue
    }

    public func presentableForwardSegue() throws -> HelmSegue {
        let fragment = try presentedFragments.last.unwrap()
        do {
            return try nav.uniqueEgressEdge(for: fragment.wrappedValue)
        } catch {
            throw ConcreteHelmError.ambiguousForwardFromFragment(fragment.wrappedValue)
        }
    }

    /// Dismisses a fragment.
    /// If the fragment is not already presented, the operation fails.
    /// If the fragment has no dismissable ingress segues, the operation fails.
    /// - note: Only the segues in the path (already visited) are considered when searching for the dismissable ingress segue.
    /// - parameter fragment: The given fragment.
    public func dismiss(fragment: N) {
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
    public func dismiss<T>(tag: T) where T: SegueTag {
        do {
            let pathEdge = try dismissablePathEdge(with: tag)
            try dismiss(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Dismisses the last presented fragment.
    /// The operation fails if the latest fragment in the path has no dismissable ingress segue.
    public func dismiss() {
        do {
            let pathEdge = try dismissableBackwardPathEdge()
            try dismiss(pathEdge: pathEdge)
        } catch {
            errors.append(error)
        }
    }

    /// Triggers a segue dismissing its out node.
    public func dismiss(pathEdge: PathEdge<N>) throws {
        try isDismissable(pathEdge: pathEdge)

        for ingressSegue in path.ingressEdges(for: pathEdge.to) {
            path.remove(ingressSegue)
        }

        let removables = path
            .disconnectedSubgraphs
            .filter {
                !$0.has(node: pathEdge.from)
            }
            .flatMap { $0 }

        path = path.subtracting(removables)
    }

    public func dismissablePathEdge(for fragment: N) throws -> PathEdge<N> {
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

    public func dismissablePathEdge<T>(with tag: T) throws -> PathEdge<N> where T: SegueTag {
        let segues = nav.filter { $0.tag == AnyHashable(tag) }

        guard let pathEdge = path.reversed().first(where: { segues.map(\.edge).contains($0.edge) })
        else {
            throw ConcreteHelmError.missingTaggedSegue(name: AnyHashable(tag))
        }

        try isDismissable(pathEdge: pathEdge)

        return pathEdge
    }

    public func dismissableBackwardPathEdge() throws -> PathEdge<N> {
        guard let pathEdge = path.last else {
            throw ConcreteHelmError.emptyPath
        }

        try isDismissable(pathEdge: pathEdge)

        return pathEdge
    }

    public func isDismissable(pathEdge: PathEdge<N>) throws {
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

    public func canDismiss(fragment: N) -> Bool {
        do {
            _ = try dismissablePathEdge(for: fragment)
            return true
        } catch {
            return false
        }
    }

    public func canDismiss<T>(using tag: T) -> Bool where T: SegueTag {
        do {
            _ = try dismissablePathEdge(with: tag)
            return true
        } catch {
            return false
        }
    }

    public func canDismiss() -> Bool {
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
    public func replace(path: HelmPath) throws {
        self.path = path
        try validate()
    }

    /// Navigates a transition calling the right method (present, dismiss or replace).
    /// - parameter transition: A transition.
    /// - throws: Throws if the transition is not valid.
    public func navigate(transition: HelmTransition) throws {
        switch transition {
        case let .present(step):
            try present(pathEdge: step)
        case let .dismiss(step):
            try dismiss(pathEdge: step)
        case let .replace(path):
            try replace(path: path)
        }
    }

    public func isPresented(_ fragment: N) -> Bool {
        return isPresented(fragment, id: String?.none)
    }

    /// Checks if a fragment is presented. Shorthand for `presentedFragments.contains(fragment)`
    /// - returns: True if the fragment is presented.
    public func isPresented<ID>(_ fragment: N, id: ID?) -> Bool where ID: PathFragmentIdentifier {
        return presentedFragments
            .contains(PathFragment(fragment, id: id))
    }

    /// The navigation graph's entry point.
    /// The entry fragment is always initially presented.
    public var entry: N {
        nav.inlets.map { $0.from }[0]
    }

    public func isPresented(_ fragment: N) -> Binding<Bool> {
        isPresented(fragment, id: String?.none)
    }

    /// A special `isPresented(fragment:)` function that returns a binding.
    /// Setting the binding value to false is the same thing as calling `dismiss(fragment:)` with the fragment as the parameter.
    /// - parameter fragment: The fragment
    /// - returns: A binding, true if the fragment is presented.
    public func isPresented<ID>(_ fragment: N, id: ID?) -> Binding<Bool> where ID: PathFragmentIdentifier {
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
    public func segue(for edge: HelmGraphEdge) throws -> HelmSegue {
        if let segue = edgeToSegueMap[edge] {
            return segue
        }
        throw ConcreteHelmError.missingSegueForEdge(edge)
    }

    /// Get all the possible transitions in the current navigation graph.
    /// This method does a deepth first search on the navigation graph while respecting all the navigation rules.
    public typealias PathFragmentIdentityProvider<ID: PathFragmentIdentifier> = (HelmGraphEdge) -> ID?
    public func transitions(from: N? = nil,
                            until: N? = nil) -> [HelmTransition]
    {
        return transitions(from: from, until: until) { _ in
            String?.none
        }
    }

    public func transitions<ID>(from: N? = nil,
                                until: N? = nil,
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
                    let nextPath = path.union([nextPathComponent])
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

        var edgeToSegue: [HelmGraphEdge: HelmSegue] = [:]

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

        guard Set(path.map(\.edge)).isSubset(of: nav.map { $0.edge }) else {
            throw ConcreteHelmError.pathMismatch(Set(path.map(\.edge)))
        }
    }

    private func calculatePresentedFragments() -> HelmPathFragments {
        var result: HelmPathFragments = [PathFragment(entry)]

        for pathEdge in path {
            guard let segue = try? segue(for: pathEdge.edge) else {
                return []
            }
            switch segue.style {
            case .hold:
                result.append(pathEdge.to)
            case .pass:
                result.remove(pathEdge.from)
                result.append(pathEdge.to)
            }
        }

        return result
    }
}
