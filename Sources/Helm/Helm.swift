//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Collections
import Foundation
import SwiftUI

/// A transition along an edge of the navigation graph.
public enum PathTransition<N: Fragment>: Hashable {
    case present(pathEdge: PathEdge<N>)
    case dismiss(pathEdge: PathEdge<N>)
    case replace(path: OrderedSet<PathEdge<N>>)
}

/// A fragment identifier used to distinguish fragments that have the same name, but display different data (i.e. a master detail list)
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

    /// Init using a regular edge and the destination fragment id.
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

/// A fragment in a path. Unlike regular fragments, path fragments have an additional id that can be used to distinguish between fragments with the same name by different data (i.e. in master-details list `(fragment: .details, id: 1)` is different from `(fragment: .details, id: 2)`.
public struct PathFragment<N: Fragment>: Fragment {
    public let wrappedValue: N
    public let id: AnyHashable?

    /// Init with a fragment
    public init(_ fragment: N) {
        wrappedValue = fragment
        id = nil
    }

    /// Init with a fragment and an id
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

/// Helm holds the navigation rules plus the presented path.
/// Has methods to navigate and list all possible transitions.
public class Helm<N: Fragment>: ObservableObject {
    public typealias HelmSegue = Segue<N>
    public typealias HelmGraph = Set<HelmSegue>
    public typealias HelmGraphEdge = DirectedEdge<N>
    public typealias HelmTransition = PathTransition<N>
    public typealias HelmPath = OrderedSet<PathEdge<N>>
    public typealias HelmPathFragments = OrderedSet<PathFragment<N>>
    internal typealias ConcreteHelmError = HelmError<N>

    /// The navigation graph describes all the navigation rules.
    public let nav: HelmGraph

    /// The presented path. It leads to the currently presented fragments.
    public internal(set) var path: HelmPath {
        didSet {
            presentedFragments = calculatePresentedFragments()
        }
    }

    /// The presented fragments.
    @Published var presentedFragments: HelmPathFragments

    /// All the errors triggered when navigating the graph.
    @Published public internal(set) var errors: [Swift.Error]

    internal let edgeToSegueMap: [HelmGraphEdge: HelmSegue]

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

        if let autoSegue = autoPresentableSegue(from: entry) {
            try present(pathEdge: PathEdge(autoSegue.edge))
        }
    }
}
