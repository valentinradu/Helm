//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation
import Helm

typealias TestGraphEdge = DirectedEdge<TestNode>
typealias TestGraph = Set<TestGraphEdge>

enum TestNode: Fragment {
    case a
    case b
    case c
    case d
    case e
    case f
    case g
    case h
    case i
    case j
}

extension DirectedEdge {
    static var ab: DirectedEdge<TestNode> { .init(from: .a, to: .b) }
    static var ac: DirectedEdge<TestNode> { .init(from: .a, to: .c) }
    static var ad: DirectedEdge<TestNode> { .init(from: .a, to: .d) }
    static var ba: DirectedEdge<TestNode> { .init(from: .b, to: .a) }
    static var bc: DirectedEdge<TestNode> { .init(from: .b, to: .c) }
    static var bd: DirectedEdge<TestNode> { .init(from: .b, to: .d) }
    static var cb: DirectedEdge<TestNode> { .init(from: .c, to: .b) }
    static var cd: DirectedEdge<TestNode> { .init(from: .c, to: .d) }
    static var ch: DirectedEdge<TestNode> { .init(from: .c, to: .h) }
    static var db: DirectedEdge<TestNode> { .init(from: .d, to: .b) }
    static var de: DirectedEdge<TestNode> { .init(from: .d, to: .e) }
    static var df: DirectedEdge<TestNode> { .init(from: .d, to: .f) }
    static var dg: DirectedEdge<TestNode> { .init(from: .d, to: .g) }
    static var dh: DirectedEdge<TestNode> { .init(from: .d, to: .h) }
    static var hf: DirectedEdge<TestNode> { .init(from: .h, to: .f) }
    static var hj: DirectedEdge<TestNode> { .init(from: .h, to: .j) }
    static var jg: DirectedEdge<TestNode> { .init(from: .j, to: .g) }
}
