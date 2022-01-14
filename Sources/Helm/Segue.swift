//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

/// Fragments represent full partial screens areas in an app.
public protocol Fragment: Node {}

/// A handler used in segue queries.
public protocol SegueTag: Hashable {}

extension AnyHashable: SegueTag {}

/// Segues are the edges between the navigation graph's fragments.
public struct Segue<N: Fragment>: DirectedConnector, Equatable {
    /// The input fragment
    public let from: N
    /// The output fragment
    public let to: N
    /// Segue rules define what happens with the origin fragment when presenting other.
    /// - seealso: `SegueRule`
    public let rule: SeguePresentationRule
    /// Whether the segue can be dismissed or not.
    public let dismissable: Bool
    /// An auto segue will automatically fire towards its destination fragment as soon as the origin fragment has been presented.
    public let auto: Bool
    /// A tag identifying the segue.
    public let tag: AnyHashable?

    /// Initializes a new segue.
    /// - parameter from: The input fragment (origin fragment)
    /// - parameter to: The output fragment (destination fragment)
    /// - parameter rule: The rule. Defaults to `.replace`.
    /// - parameter dismissable: A dismissable segue is allowed to return to the origin fragment.
    /// - parameter auto: Sets the auto firing behaviour. A fragment can only have one egress auto segue. Defaults to `false`.
    /// - parameter tag: A tag identifying the segue. Defaults to `nil`.
    public init(from: N,
                to: N,
                rule: SeguePresentationRule = .replace,
                dismissable: Bool = false,
                auto: Bool = false)
    {
        self.from = from
        self.to = to
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = nil
    }

    public init<T: SegueTag>(from: N,
                             to: N,
                             rule: SeguePresentationRule = .replace,
                             dismissable: Bool = false,
                             auto: Bool = false,
                             tag: T? = nil)
    {
        self.from = from
        self.to = to
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = tag
    }
    
    public init(_ edge: DirectedEdge<N>,
                rule: SeguePresentationRule = .replace,
                dismissable: Bool = false,
                auto: Bool = false)
    {
        self.from = edge.from
        self.to = edge.to
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = nil
    }

    public init<T: SegueTag>(_ edge: DirectedEdge<N>,
                             rule: SeguePresentationRule = .replace,
                             dismissable: Bool = false,
                             auto: Bool = false,
                             tag: T? = nil)
    {
        self.from = edge.from
        self.to = edge.to
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = tag
    }

    /// Returns a modified auto copy of the segue.
    public func makeAuto() -> Self {
        Segue(from: from,
              to: to,
              rule: rule,
              dismissable: dismissable,
              auto: true,
              tag: tag)
    }

    /// Returns a modified dismissable copy of the segue.
    public func makeDismissable() -> Self {
        Segue(from: from,
              to: to,
              rule: rule,
              dismissable: true,
              auto: auto,
              tag: tag)
    }

    /// Returns a modified copy of the segue, setting the tag.
    public func with<T: SegueTag>(tag: T) -> Self {
        Segue(from: from,
              to: to,
              rule: rule,
              dismissable: dismissable,
              auto: auto,
              tag: tag)
    }

    /// Returns a modified copy of the segue, setting the presentation rule.
    public func with(rule: SeguePresentationRule) -> Self {
        Segue(from: from,
              to: to,
              rule: rule,
              dismissable: dismissable,
              auto: auto,
              tag: tag)
    }
}

/// Segue rules define what happens with the origin fragment when presenting other fragment.
public enum SeguePresentationRule: Hashable {
    /// The origin fragment keeps its presented status. Both the origin and the destination fragment will be presented after walking the segue.
    case hold
    /// The origin fragment loses its presented status. Only the destination fragment will be presented after walking the segue.
    case replace
}
