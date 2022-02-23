//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation
import Helm

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

enum TestTag: SegueTag {
    case menu
}

extension DirectedEdge where N == TestNode {
    static var aa: Self { .a => .a }
    static var ab: Self { .a => .b }
    static var ac: Self { .a => .c }
    static var ad: Self { .a => .d }
    static var ba: Self { .b => .a }
    static var bc: Self { .b => .c }
    static var bb: Self { .b => .b }
    static var bd: Self { .b => .d }
    static var be: Self { .b => .e }
    static var cb: Self { .c => .b }
    static var cd: Self { .c => .d }
    static var ca: Self { .c => .a }
    static var ce: Self { .c => .e }
    static var ch: Self { .c => .h }
    static var cc: Self { .c => .c }
    static var db: Self { .d => .b }
    static var de: Self { .d => .e }
    static var df: Self { .d => .f }
    static var dg: Self { .d => .g }
    static var dh: Self { .d => .h }
    static var eb: Self { .e => .b }
    static var hf: Self { .h => .f }
    static var hj: Self { .h => .j }
    static var jg: Self { .j => .g }
}

extension PathEdge where N == TestNode {
    static var aa: Self { .init(.a => .a, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ab: Self { .init(.a => .b, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ac: Self { .init(.a => .c, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ad: Self { .init(.a => .d, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ba: Self { .init(.b => .a, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var bb: Self { .init(.b => .b, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var bc: Self { .init(.b => .c, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var bd: Self { .init(.b => .d, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var be: Self { .init(.b => .e, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ca: Self { .init(.c => .a, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var cb: Self { .init(.c => .b, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var cc: Self { .init(.c => .c, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var cd: Self { .init(.c => .d, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ce: Self { .init(.c => .e, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var ch: Self { .init(.c => .h, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var db: Self { .init(.d => .b, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var de: Self { .init(.d => .e, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var df: Self { .init(.d => .f, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var dg: Self { .init(.d => .g, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var dh: Self { .init(.d => .h, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var eb: Self { .init(.e => .b, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var hf: Self { .init(.h => .f, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var hj: Self { .init(.h => .j, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
    static var jg: Self { .init(.j => .g, sourceId: AnyHashable?.none, targetId: AnyHashable?.none) }
}

extension Segue where N == TestNode {
    static var aa: Self { .init(from: .a, to: .a) }
    static var ab: Self { .init(from: .a, to: .b) }
    static var ac: Self { .init(from: .a, to: .c) }
    static var ad: Self { .init(from: .a, to: .d) }
    static var ba: Self { .init(from: .b, to: .a) }
    static var bc: Self { .init(from: .b, to: .c) }
    static var bd: Self { .init(from: .b, to: .d) }
    static var bb: Self { .init(from: .b, to: .b) }
    static var be: Self { .init(from: .b, to: .e) }
    static var cb: Self { .init(from: .c, to: .b) }
    static var cd: Self { .init(from: .c, to: .d) }
    static var ce: Self { .init(from: .c, to: .e) }
    static var ch: Self { .init(from: .c, to: .h) }
    static var ca: Self { .init(from: .c, to: .a) }
    static var db: Self { .init(from: .d, to: .b) }
    static var de: Self { .init(from: .d, to: .e) }
    static var df: Self { .init(from: .d, to: .f) }
    static var cc: Self { .init(from: .c, to: .c) }
    static var dg: Self { .init(from: .d, to: .g) }
    static var dh: Self { .init(from: .d, to: .h) }
    static var eb: Self { .init(from: .e, to: .b) }
    static var hf: Self { .init(from: .h, to: .f) }
    static var hj: Self { .init(from: .h, to: .j) }
    static var jg: Self { .init(from: .j, to: .g) }
}

extension Array where Element == Segue<TestNode> {
    func makeAuto() -> Self {
        map {
            $0.makeAuto()
        }
    }

    func makeDismissable() -> Self {
        map {
            $0.makeDismissable()
        }
    }

    func with(rule: SeguePresentationStyle) -> Self {
        map {
            $0.with(style: rule)
        }
    }
}
