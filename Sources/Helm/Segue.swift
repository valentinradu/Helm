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

/// Segues are the edges between the navigation graph's fragments.
public struct Segue<N: Fragment>: DirectedConnectable, Equatable {
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
    /// - parameter in: The input fragment (origin fragment)
    /// - parameter out: The output fragment (destination fragment)
    /// - parameter rule: The rule. Defaults to `.replace`.
    /// - parameter dismissable: A dismissable segue is allowed to return to the origin fragment.
    /// - parameter auto: Sets the auto firing behaviour. A fragment can only have one egress auto segue. Defaults to `false`.
    /// - parameter tag: A tag identifying the segue. Defaults to `nil`.
    public init(_ in: N,
                to out: N,
                rule: SeguePresentationRule = .replace,
                dismissable: Bool = false,
                auto: Bool = false)
    {
        self.from = `in`
        self.to = out
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = nil
    }

    public init<T: SegueTag>(_ in: N,
                             to out: N,
                             rule: SeguePresentationRule = .replace,
                             dismissable: Bool = false,
                             auto: Bool = false,
                             tag: T? = nil)
    {
        self.from = `in`
        self.to = out
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = tag
    }
}

/// Segue rules define what happens with the origin fragment when presenting other fragment.
public enum SeguePresentationRule: Hashable {
    /// The origin fragment keeps its presented status. Both the origin and the destination fragment will be presented after walking the segue.
    case hold
    /// The origin fragment loses its presented status. Only the destination fragment will be presented after walking the segue.
    case replace
}
