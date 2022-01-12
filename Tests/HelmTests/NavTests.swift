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
private typealias TestGraphError = HelmError<TestGraphSegue>

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

        let cycle = Set([.bc, .cb].auto())
        let autoCycleGraph = TestGraph(
            [.ab] + cycle
        )
        XCTAssertThrowsError(try Helm(nav: autoCycleGraph),
                             TestGraphError.autoCycleDetected(cycle).localizedDescription)
        
        let multiSeguesPerEdgeGraph = TestGraph([.ab, .bc] + [.bc].auto())
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
        let graph = TestGraph([.ab].dismissable())
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
        let nav = try Helm(nav: TestGraph([.ab] + [.ac].dismissable()), path: [.ab])
        XCTAssertThrowsError(try nav.dismiss(edge: .db),
                             TestGraphError.missingSegueForEdge(.db).localizedDescription)
        XCTAssertThrowsError(try nav.dismiss(edge: .ab),
                             TestGraphError.segueNotDismissable(.ab).localizedDescription)
        XCTAssertThrowsError(try nav.dismiss(edge: .ac),
                             TestGraphError.fragmentNotPresented(.c).localizedDescription)
    }
    
    func testDismissEdge() throws {
        let graph = TestGraph(
            [.ab]
                + [.bc].dismissable().rule(.hold)
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
        let graph = TestGraph([.ab] + [.bc].dismissable())
        let nav = try Helm(nav: graph)
        
        nav.dismiss()
        
        XCTAssertTrue(nav.isPresented(.a))
        XCTAssertEqual(nav.errors.count, 1)
    }
    
    func testDismissLast() throws {
        let graph = TestGraph([.ab] + [.bc].dismissable())
        let nav = try Helm(nav: graph, path: [.ab, .bc])
        
        nav.dismiss()
        
        XCTAssertTrue(nav.isPresented(.b))
        XCTAssertEqual(nav.path, [.ab])
        XCTAssertEqual(nav.errors.count, 0)
    }
}
