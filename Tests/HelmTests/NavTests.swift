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

class NavTests: XCTestCase {
    func testInitFail() {
        let emptyGraph = TestGraph([])
        XCTAssertThrowsError(try Helm(nav: emptyGraph),
                             TestGraphError.empty.localizedDescription)

        let noInletsGraph = TestGraph([.ab, .ba])
        XCTAssertThrowsError(try Helm(nav: noInletsGraph),
                             TestGraphError.missingInlets.localizedDescription)
        
        let multiInletsGraph = TestGraph([.ab, .cd])
        XCTAssertThrowsError(try Helm(nav: multiInletsGraph),
                             TestGraphError.ambiguousInlets.localizedDescription)

        let cycle = TestGraph([.bc, .cb].makeAuto())
        let autoCycleGraph = TestGraph(
            [.ab] + cycle
        )
        XCTAssertThrowsError(try Helm(nav: autoCycleGraph),
                             TestGraphError.autoCycleDetected(cycle).localizedDescription)
        
        let multiSeguesPerEdgeGraph = TestGraph([.ab, .bc] + [.bc].makeAuto())
        XCTAssertThrowsError(try Helm(nav: multiSeguesPerEdgeGraph),
                             TestGraphError.oneEdgeToManySegues([.bc]).localizedDescription)
        
        let mismatchPathGraph = TestGraph([.ab, .bc])
        XCTAssertThrowsError(try Helm(nav: mismatchPathGraph, path: [.ac]),
                             TestGraphError.pathMismatch([.ac]).localizedDescription)
    }
    
    func testEntry() throws {
        let graph = TestGraph([.ab, .ac, .ad])
        let helm = try Helm(nav: graph)
        XCTAssertEqual(helm.entry, .a)
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
        let nav = try Helm(nav: TestGraph([.ab] + [.ac].makeDismissable()), path: [.ab])
        XCTAssertThrowsError(try nav.dismiss(edge: .db),
                             TestGraphError.missingSegueForEdge(.db).localizedDescription)
        XCTAssertThrowsError(try nav.dismiss(edge: .ab),
                             TestGraphError.segueNotDismissable(.ab).localizedDescription)
        XCTAssertThrowsError(try nav.dismiss(edge: .ac),
                             TestGraphError.missingPathEdge(.ac).localizedDescription)
    }
    
    func testDismissEdge() throws {
        let graph = TestGraph(
            [.ab]
                + [.bc].makeDismissable().with(rule: .hold)
                + [.cd]
        )
        let nav = try Helm(nav: graph, path: [.ab, .bc, .cd])
        
        try nav.dismiss(edge: .bc)
        
        XCTAssertFalse(nav.isPresented(.a))
        XCTAssertTrue(nav.isPresented(.b))
        XCTAssertFalse(nav.isPresented(.d))
        XCTAssertFalse(nav.isPresented(.c))
        XCTAssertEqual(nav.path, [.ab])
    }
    
    func testDismissLastFail() throws {
        let graph = TestGraph([.ab] + [.bc].makeDismissable())
        let nav = try Helm(nav: graph)
        
        nav.dismiss()
        
        XCTAssertTrue(nav.isPresented(.a))
        XCTAssertEqual(nav.errors.count, 1)
    }
    
    func testDismissLast() throws {
        let graph = TestGraph([.ab] + [.bc].makeDismissable())
        let nav = try Helm(nav: graph, path: [.ab, .bc])
        
        nav.dismiss()
        
        XCTAssertTrue(nav.isPresented(.b))
        XCTAssertEqual(nav.path, [.ab])
        XCTAssertEqual(nav.errors as? [TestGraphError], [])
    }
    
    func testDismissTagFail() throws {
        let graph = TestGraph([.ab.makeDismissable(), .bc])
        let nav = try Helm(nav: graph, path: [.ab, .bc])
        
        let tag = TestTag.menu
        nav.dismiss(tag: tag)
        
        XCTAssertEqual(nav.errors as? [TestGraphError],
                       [.missingTaggedSegue(name: AnyHashable(tag))])
    }
    
    func testDismissTag() throws {
        let graph = TestGraph([.ab.makeDismissable().with(tag: TestTag.menu), .bc])
        let nav = try Helm(nav: graph, path: [.ab, .bc])
    }
    
    func testDismissFragmentFail() throws {
        let graph = TestGraph([.ab, .bc])
        let nav = try Helm(nav: graph, path: [.ab, .bc])
        
        nav.dismiss(fragment: .c)
        XCTAssertEqual(nav.errors as? [TestGraphError],
                       [.fragmentMissingDismissableSegue(.c)])
    }
    
    func testDismissFragment() throws {
        let graph = TestGraph([.ab] + [.bc].makeDismissable())
        let nav = try Helm(nav: graph, path: [.ab, .bc])
        
        nav.dismiss(fragment: .c)
        
        XCTAssertTrue(nav.isPresented(.b))
        XCTAssertEqual(nav.path, [.ab])
        XCTAssertEqual(nav.errors as? [TestGraphError], [])
    }
    
    func testPresentEdgeFail() throws {
        let graph = TestGraph([.ab, .bc, .cd])
        let nav = try Helm(nav: graph, path: [.ab])
        
        XCTAssertThrowsError(try nav.present(edge: .db),
                             TestGraphError.missingSegueForEdge(.db).localizedDescription)
        XCTAssertThrowsError(try nav.present(edge: .cd),
                             TestGraphError.fragmentNotPresented(.c).localizedDescription)
    }
    
    func testPresentEdge() throws {
        let graph = TestGraph([.ab, .bc, .cd])
        let nav = try Helm(nav: graph, path: [.ab])
        
        try nav.present(edge: .bc)
        
        XCTAssertTrue(nav.isPresented(.c))
        XCTAssertEqual(nav.path, [.ab, .bc])
    }
    
    func testForwardFail() throws {
        let graph = TestGraph([.ab, .ac, .bc, .bd])
        let nav = try Helm(nav: graph)
        
        nav.forward()
        
        XCTAssertTrue(nav.isPresented(.a))
        XCTAssertFalse(nav.isPresented(.c))
        XCTAssertFalse(nav.isPresented(.b))
        
        nav.present(fragment: .b)
        nav.forward()
        
        XCTAssertTrue(nav.isPresented(.b))
        XCTAssertFalse(nav.isPresented(.c))
        XCTAssertFalse(nav.isPresented(.d))
        XCTAssertEqual(nav.errors as? [TestGraphError],
                       [
                           .ambiguousForwardFromFragment(.a),
                           .ambiguousForwardFromFragment(.b)
                       ])
    }
    
    func testForward() throws {
        let graph = TestGraph([.ab, .bc, .cd])
        let nav = try Helm(nav: graph)
        
        nav.forward()
        
        XCTAssertFalse(nav.isPresented(.a))
        XCTAssertTrue(nav.isPresented(.b))
        XCTAssertFalse(nav.isPresented(.c))
        XCTAssertEqual(nav.errors as? [TestGraphError], [])
        
        nav.forward()
        
        XCTAssertFalse(nav.isPresented(.a))
        XCTAssertFalse(nav.isPresented(.b))
        XCTAssertTrue(nav.isPresented(.c))
        XCTAssertEqual(nav.errors as? [TestGraphError], [])
    }
}
