//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

public protocol Section: Node {}

/// Segues are the edges between the navigation graph's sections.
public struct Segue<S: Section>: DirectedConnectable, Equatable {
    /// The input section
    public let `in`: S
    /// The output section
    public let out: S
    /// Segue rules define what happens with the origin section when presenting other.
    /// - seealso: `SegueRule`
    public let rule: SegueRule
    /// Whether the segue can be dismissed or not.
    public let dismissable: Bool
    /// An auto segue will automatically fire towards its destination section as soon as the origin section has been presented.
    public let auto: Bool

    /// Initializes a new segue.
    /// - parameter in: The input section (origin section)
    /// - parameter out: The output section (destination section)
    /// - parameter dismissable: A dismissable segue is allowed to return to the origin section.
    /// - parameter rule: The rule. Defaults to `.replace`.
    /// - parameter auto: Sets the auto firing behaviour. Defaults to `false`.
    public init(_ in: S,
                to out: S,
                rule: SegueRule = .replace,
                dismissable: Bool = false,
                auto: Bool = false)
    {
        self.in = `in`
        self.out = out
        self.rule = rule
        self.dismissable = dismissable
        self.auto = auto
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.in)
        hasher.combine(self.out)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return
            lhs.in == rhs.in &&
            lhs.out == rhs.out
    }
}

/// Segue rules define what happens with the origin section when presenting other section.
public enum SegueRule: Hashable {
    /// The origin section keeps its presented status. Both the origin and the destination section will be presented after walking the segue.
    case hold
    /// The origin section loses its presented status. Only the destination section will be presented after walking the segue.
    case replace
}
