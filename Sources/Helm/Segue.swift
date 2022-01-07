//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation

/// A node is the atomic unit in a navigation graph. It usually represents a screen or a part of a screen in your app.
public protocol Node: Hashable {}

/// Segues are the edges between the navigation graph's nodes.
public struct Segue<N: Node>: Hashable, CustomDebugStringConvertible {
    /// The input node
    let `in`: N
    /// The output node
    let out: N
    /// Segue grants define what happens with the origin node when presenting another node.
    /// - seealso: `SegueGrant`
    let grant: SegueGrant
    /// An auto segue will automatically fire towards the destination node as soon as the origin node is reached.
    let auto: Bool

    /// Initializes a new segue.
    /// - parameter in: The input node (origin node)
    /// - parameter out: The output node (destination node)
    /// - parameter grant: The grant type. Defaults to `.pass`.
    /// - parameter auto: Sets the auto firing behaviour. Defaults to `false`.
    public init(_ in: N, to out: N, grant: SegueGrant = .pass, auto: Bool = false) {
        self.in = `in`
        self.out = out
        self.grant = grant
        self.auto = auto
    }

    public var debugDescription: String {
        return "\(self.in) => \(out)"
    }
    
    /// The segue node relationship
    public var rel: SegueRel<N> {
        SegueRel(`in`, to: out)
    }
}

/// Segue grants define what happens with the origin node when presenting another node.
public enum SegueGrant: Hashable {
    /// The origin node keeps its presented status. Both the origin and the destination node will be presented after walking the segue.
    case keep
    /// The origin node loses its presented status. Only the destination node will be presented after walking the segue.
    case pass
}

/// The relationship between two nodes. Similar to a segue, but stripped of the navigation-related data.
public struct SegueRel<N: Node>: Hashable {
    /// The input node
    let `in`: N
    /// The output node
    let out: N
    
    /// Initializes a new segue.
    /// - parameter in: The input node (origin node)
    /// - parameter out: The output node (destination node)
    public init(_ in: N, to out: N) {
        self.in = `in`
        self.out = out
    }
    
    /// Constructs a segue from the rel providing the grant and auto nav data.
    /// - parameter grant: The grant type. Defaults to `.pass`.
    /// - parameter auto: Sets the auto firing behaviour. Defaults to `false`.
    public func segue(grant: SegueGrant = .pass, auto: Bool = false) -> Segue<N> {
        Segue(`in`, to: out, grant: grant, auto: auto)
    }
}
