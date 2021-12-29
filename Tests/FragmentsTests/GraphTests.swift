//
//  File.swift
//
//
//  Created by Valentin Radu on 29/12/2021.
//

import Foundation
@testable import Fragments
import XCTest

final class GraphTests: XCTestCase {
    func testEditExistingSegue() {}

    func testEditMissingSegue() {}

    func testExclusiveSegue() {}
    
    func testCoverSegue() {}
    
    func testUnreachablePresentedNode() {}
    
    func testUnreachablePresentedFlow() {}
    
    func testNextSegue() {}
    
    func testNextSegueMissing() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        var flow = Flow<TestNode>()
        flow.add(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph.present(node: .a)
        graph.next()
        
        XCTAssertEqual(graph.activeFlow.segues, [])
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }
    
    func testPrevSegue() {}
    
    func testPrevSegueMissing() {}
    
    func testDismissSegue() {}
    
    func testDismissSegueNoContext() {}
    
    func testIsPresented() {}
    
    func testIsPresentedBindingContextSegue() {}
    
    func testIsPresentedBindingRegularSegue() {}
}
