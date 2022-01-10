//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

/// Sections represent full partial screens areas in an app.
public protocol Section: Node {}

/// A handler used in segue queries.
public protocol SegueTag: Hashable {}

/// Segues are the edges between the navigation graph's sections.
public struct Segue<N: Section>: DirectedConnectable, Equatable {
    /// The input section
    public let `in`: N
    /// The output section
    public let out: N
    /// Segue rules define what happens with the origin section when presenting other.
    /// - seealso: `SegueRule`
    public let rule: SeguePresentationRule
    /// Whether the segue can be dismissed or not.
    public let dismissable: Bool
    /// An auto segue will automatically fire towards its destination section as soon as the origin section has been presented.
    public let auto: Bool
    /// A tag identifying the segue.
    public let tag: AnyHashable?

    /// Initializes a new segue.
    /// - parameter in: The input section (origin section)
    /// - parameter out: The output section (destination section)
    /// - parameter rule: The rule. Defaults to `.replace`.
    /// - parameter dismissable: A dismissable segue is allowed to return to the origin section.
    /// - parameter auto: Sets the auto firing behaviour. A section can only have one egress auto segue. Defaults to `false`.
    /// - parameter tag: A tag identifying the segue. Defaults to `nil`.
    public init(_ in: N,
                to out: N,
                rule: SeguePresentationRule = .replace,
                dismissable: Bool = false,
                auto: Bool = false)
    {
        self.in = `in`
        self.out = out
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        tag = nil
    }

    public init<T: SegueTag>(_ in: N,
                             to out: N,
                             rule: SeguePresentationRule = .replace,
                             dismissable: Bool = false,
                             auto: Bool = false,
                             tag: T? = nil)
    {
        self.in = `in`
        self.out = out
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
        self.tag = tag
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.in)
        hasher.combine(out)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return
            lhs.in == rhs.in &&
            lhs.out == rhs.out
    }
}

/// Segue rules define what happens with the origin section when presenting other section.
public enum SeguePresentationRule: Hashable {
    /// The origin section keeps its presented status. Both the origin and the destination section will be presented after walking the segue.
    case hold
    /// The origin section loses its presented status. Only the destination section will be presented after walking the segue.
    case replace
}
