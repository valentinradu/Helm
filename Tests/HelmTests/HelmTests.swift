//
//  File.swift
//
//
//  Created by Valentin Radu on 12/01/2022.
//

import Foundation
import SwiftUI

@testable import Helm
import XCTest

private typealias TestGraphSegue = Segue<TestNode>
private typealias TestGraph = Set<TestGraphSegue>
private typealias TestGraphError = HelmError<TestNode>

class HelmTests: XCTestCase {
    func testInitFail() {
        let emptyGraph = TestGraph([])
        XCTAssertThrowsError(try Helm(nav: emptyGraph),
                             TestGraphError.empty.description)

        let noInletsGraph = TestGraph([.ab, .ba])
        XCTAssertThrowsError(try Helm(nav: noInletsGraph),
                             TestGraphError.missingInlets.description)

        let multiInletsGraph = TestGraph([.ab, .cd])
        XCTAssertThrowsError(try Helm(nav: multiInletsGraph),
                             TestGraphError.ambiguousInlets.description)

        let cycle = TestGraph([.bc, .cb].makeAuto())
        let autoCycleGraph = TestGraph(
            [.ab] + cycle
        )
        XCTAssertThrowsError(try Helm(nav: autoCycleGraph),
                             TestGraphError.autoCycleDetected(cycle).description)

        let multiSeguesPerEdgeGraph = TestGraph([.ab, .bc] + [.bc].makeAuto())
        XCTAssertThrowsError(try Helm(nav: multiSeguesPerEdgeGraph),
                             TestGraphError.oneEdgeToManySegues([.bc]).description)

        let mismatchPathGraph = TestGraph([.ab, .bc])
        XCTAssertThrowsError(try Helm(nav: mismatchPathGraph, path: [.ac]),
                             TestGraphError.pathMismatch([.ac]).description)
    }

    func testEntry() throws {
        let graph = TestGraph([.ab, .ac, .ad])
        let helm = try Helm(nav: graph)
        XCTAssertEqual(helm.entry, .a)
    }

    func testAutoEntry() throws {
        let graph = TestGraph([.ab.makeAuto(), .ac, .ad])
        let helm = try Helm(nav: graph)

        XCTAssertTrue(helm.isPresented(.b))
    }

    func testCyclicPath() throws {
        let graph = TestGraph([.ab, .bc, .cb])
        let helm = try Helm(nav: graph, path: [.ab])

        helm.present(fragment: .c)

        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.c))

        helm.present(fragment: .b)

        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.c))

        helm.present(fragment: .c)

        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.c))
    }

    func testIsPresented() throws {
        let graph = TestGraph([.ab].makeDismissable())
        let helm = try Helm(nav: graph, path: [.ab])

        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.a))

        let binding: Binding<Bool> = helm.isPresented(.b)

        binding.wrappedValue = false

        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.a))

        binding.wrappedValue = true

        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.a))
    }

    func testDismissEdgeFail() throws {
        let helm = try Helm(nav: TestGraph([.ab] + [.ac].makeDismissable()), path: [.ab])
        XCTAssertThrowsError(try helm.dismiss(pathEdge: .db),
                             TestGraphError.missingSegueForEdge(.db).description)
        XCTAssertThrowsError(try helm.dismiss(pathEdge: .ab),
                             TestGraphError.segueNotDismissable(.ab).description)
        XCTAssertThrowsError(try helm.dismiss(pathEdge: .ac),
                             TestGraphError.missingPathEdge(.ac).description)
    }

    func testDismissEdge() throws {
        let graph = TestGraph(
            [.ab]
                + [.bc].makeDismissable().with(rule: .hold)
                + [.cd]
        )
        let helm = try Helm(nav: graph, path: [.ab, .bc, .cd])

        try helm.dismiss(pathEdge: .bc)

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.d))
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertEqual(helm.path, [.ab])
    }

    func testDismissLastFail() throws {
        let graph = TestGraph([.ab] + [.bc])
        let helm = try Helm(nav: graph)

        helm.dismiss()
        helm.present(fragment: .b)
        helm.present(fragment: .c)
        helm.dismiss()

        XCTAssertEqual(helm.errors as? [TestGraphError], [
            TestGraphError.emptyPath,
            TestGraphError.noDismissableSegues
        ])
    }

    func testDismissLast() throws {
        let graph = TestGraph([.ab] + [.bc].makeDismissable() + [.cd])
        let helm = try Helm(nav: graph, path: [.ab, .bc, .cd])

        helm.dismiss()

        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertEqual(helm.path, [.ab])
        XCTAssertEqual(helm.errors as? [TestGraphError], [])
    }

    func testDismissTagFail() throws {
        let graph = TestGraph([.ab.makeDismissable(), .bc])
        let helm = try Helm(nav: graph, path: [.ab, .bc])

        let tag = TestTag.menu
        helm.dismiss(tag: tag)

        XCTAssertEqual(helm.errors as? [TestGraphError],
                       [.missingTaggedSegue(name: AnyHashable(tag))])
    }

    func testDismissTag() throws {
        let tag = TestTag.menu
        let graph = TestGraph([.ab.makeDismissable().with(tag: tag), .bc])
        let helm = try Helm(nav: graph, path: [.ab, .bc])

        helm.dismiss(tag: tag)

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertEqual(helm.errors as? [TestGraphError], [])
    }

    func testDismissFragmentFail() throws {
        let graph = TestGraph([.ab, .bc])
        let helm = try Helm(nav: graph, path: [.ab, .bc])

        helm.dismiss(fragment: .c)
        XCTAssertEqual(helm.errors as? [TestGraphError],
                       [.fragmentMissingDismissableSegue(.c)])
    }

    func testDismissFragment() throws {
        let graph = TestGraph([.ab] + [.bc].makeDismissable())
        let helm = try Helm(nav: graph, path: [.ab, .bc])

        helm.dismiss(fragment: .c)

        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertEqual(helm.path, [.ab])
        XCTAssertEqual(helm.errors as? [TestGraphError], [])
    }

    func testPresentEdge() throws {
        let graph = TestGraph([.ab, .bc, .cd])
        let helm = try Helm(nav: graph, path: [.ab])

        try helm.present(pathEdge: .bc)

        XCTAssertTrue(helm.isPresented(.c))
        XCTAssertEqual(helm.path, [.ab, .bc])
    }

    func testForwardFail() throws {
        let graph = TestGraph([.ab, .ac, .bc, .bd])
        let helm = try Helm(nav: graph)

        helm.forward()

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertFalse(helm.isPresented(.b))

        helm.present(fragment: .b)
        helm.forward()

        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertFalse(helm.isPresented(.d))
        XCTAssertEqual(helm.errors as? [TestGraphError],
                       [
                           .ambiguousForwardFromFragment(.a),
                           .ambiguousForwardFromFragment(.b),
                       ])
    }

    func testForward() throws {
        let graph = TestGraph([.ab, .bc, .cd])
        let helm = try Helm(nav: graph)

        helm.forward()

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertEqual(helm.errors as? [TestGraphError], [])

        helm.forward()

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.c))
        XCTAssertEqual(helm.errors as? [TestGraphError], [])
    }

    func testPresentTagFail() throws {
        let tag = TestTag.menu
        let graph = TestGraph([.ab])
        let helm = try Helm(nav: graph, path: [.ab])

        helm.present(tag: tag)

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertEqual(helm.errors as? [TestGraphError],
                       [.missingTaggedSegue(name: AnyHashable(tag))])
    }

    func testPresentTag() throws {
        let tag = TestTag.menu
        let graph = TestGraph([.ab.with(tag: tag)])
        let helm = try Helm(nav: graph)

        helm.present(tag: tag)

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertEqual(helm.errors as? [TestGraphError], [])
    }

    func testPresentFragmentFail() throws {
        let graph = TestGraph([.ab, .ac, .cd])
        let helm = try Helm(nav: graph)

        helm.present(fragment: .d)

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.d))

        helm.present(fragment: .c)
        helm.present(fragment: .b)

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.c))

        XCTAssertEqual(helm.errors as? [TestGraphError],
                       [.missingSegueToFragment(.d),
                        .missingSegueToFragment(.b)])
    }

    func testPresentFragment() throws {
        let graph = TestGraph([.ab, .ac, .cd])
        let helm = try Helm(nav: graph)

        helm.present(fragment: .c)

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.c))

        helm.present(fragment: .d)

        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertTrue(helm.isPresented(.d))

        XCTAssertEqual(helm.errors as? [TestGraphError], [])
    }

    func testPickPresented() throws {
        let graph = TestGraph([
            .ab.makeDismissable(),
            .ac.makeDismissable(),
            .bc, .cb,
        ])
        let helm = try Helm(nav: graph, path: [.ab])

        let binding = helm.pickPresented([.b, .c])

        XCTAssertEqual(binding.wrappedValue, .b)

        helm.present(fragment: .c)

        XCTAssertEqual(binding.wrappedValue, .c)

        binding.wrappedValue = .b

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertTrue(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.c))

        binding.wrappedValue = nil

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.c))
    }

    func testReplacePathFail() throws {
        let graph = TestGraph([.ab, .bc, .cd])
        let helm = try Helm(nav: graph, path: [.ab])

        XCTAssertThrowsError(try helm.replace(path: [.ac]),
                             TestGraphError.missingSegueForEdge(.db).description)
    }

    func testReplacePath() throws {
        let graph = TestGraph([.ab, .ac.with(style: .hold)])
        let helm = try Helm(nav: graph, path: [.ab])

        try helm.replace(path: [.ac])

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.c))
    }

    func testTransitions() throws {
        let graph = TestGraph([.ab, .ac, .ad, .bc, .bd, .cd, .db])
        let helm = try Helm(nav: graph)

        let transitions = helm.transitions()
        XCTAssertEqual(transitions,
                       [
                           .present(pathEdge: .ad),
                           .present(pathEdge: .db),
                           .present(pathEdge: .bd),
                           .replace(path: [.ad, .db]),
                           .present(pathEdge: .bc),
                           .present(pathEdge: .cd),
                           .replace(path: []),
                           .present(pathEdge: .ac),
                           .replace(path: []),
                           .present(pathEdge: .ab),
                       ])

        for transition in transitions {
            XCTAssertNoThrow(try helm.navigate(transition: transition))
        }
    }

    func testFragmentIdentity() throws {
        let graph = TestGraph([.ab.makeDismissable()])
        let helm = try Helm(nav: graph)

        helm.present(fragment: .b, id: 1)

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.b, id: 1))

        helm.dismiss(fragment: .b)

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.b, id: 1))
    }

    func testFragmentIdentityBinding() throws {
        let graph = TestGraph([.ab.makeDismissable()])
        let helm = try Helm(nav: graph)

        let binding: Binding<Bool> = helm.isPresented(.b, id: 1)

        binding.wrappedValue = true

        XCTAssertFalse(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertTrue(helm.isPresented(.b, id: 1))

        binding.wrappedValue = false

        XCTAssertTrue(helm.isPresented(.a))
        XCTAssertFalse(helm.isPresented(.b))
        XCTAssertFalse(helm.isPresented(.b, id: 1))
    }
    
    func testDisconectedPresentedNodes() throws {
        let graph = TestGraph([.ab, .bc, .ce, .cd.with(style: .hold)])
        let helm = try Helm(nav: graph, path: [.ab, .bc, .cd])
        
        XCTAssertTrue(helm.isPresented(.c))
        XCTAssertTrue(helm.isPresented(.d))
        
        helm.present(fragment: .e)
        
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertFalse(helm.isPresented(.d))
    }
}
