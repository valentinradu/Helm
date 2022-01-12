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
    func testValidation() {
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
    
    func testPresent() throws {
        let graph = TestGraph([.ab, .bc].dismissable())
        let helm = try Helm(nav: graph, path: [.ab, .bc])
        
        XCTAssertTrue(helm.isPresented(.c))
        XCTAssertFalse(helm.isPresented(.b))
        
        let binding: Binding<Bool> = helm.isPresented(.c)
        
        binding.wrappedValue = false
        
        XCTAssertFalse(helm.isPresented(.c))
        XCTAssertTrue(helm.isPresented(.b))
        
        binding.wrappedValue = true
        
        XCTAssertTrue(helm.isPresented(.c))
        XCTAssertFalse(helm.isPresented(.b))
    }
}
