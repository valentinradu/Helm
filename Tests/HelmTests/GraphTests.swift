//
//  File.swift
//
//
//  Created by Valentin Radu on 29/12/2021.
//

import Foundation
@testable import Helm
import SwiftUI
import XCTest

final class GraphTests: XCTestCase {
    func testEditExistingSegue() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        let op = graph.edit(segue: .a => .b)
        XCTAssertEqual(op.segues, [Segue(.a, to: .b)])
    }

    func testEditMissingSegue() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        let op = graph.edit(segue: .b => .c)
        XCTAssertEqual(op.segues, [])
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }

    func testPresentExclusively() {
        let flow = Flow<TestNode>(segue: .a => [.b, .c, .d])
            .add(segue: .b => .e)
        let graph = NavigationGraph(flow: flow)
        
        graph.present(flow: Flow(segue: .b => .e))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.e))
        XCTAssertFalse(graph.isPresented(.c))
        XCTAssertFalse(graph.isPresented(.d))
        
        graph.present(node: .c)
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.e))
        XCTAssertTrue(graph.isPresented(.c))
        XCTAssertFalse(graph.isPresented(.d))
    }
    
    func testPresentInclusively() {
        let flow = Flow<TestNode>(segue: .a => [.b, .c, .d])
            .add(segue: .b => .e)
        let graph = NavigationGraph(flow: flow)
        
        graph.edit(segue: .a => .b)
            .add(trait: .modal)
        graph.edit(segue: .a => .c)
            .add(trait: .cover)
        
        graph.present(node: .d)
        graph.present(flow: Flow(segue: .b => .e))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.e))
        XCTAssertFalse(graph.isPresented(.c))
        XCTAssertTrue(graph.isPresented(.d))
        
        graph.present(node: .c)
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.e))
        XCTAssertTrue(graph.isPresented(.c))
        XCTAssertTrue(graph.isPresented(.d))
    }
    
    func testUnreachablePresentedNode() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        
        graph.present(node: .c)
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
        
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }
    
    func testUnreachablePresentedFlow() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        let flow = Flow<TestNode>(segue: .a => .b => .c => .d)
        let graph = NavigationGraph(flow: flow)
        
        graph.present(node: .c)
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
        
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }
    
    func testAutoForward() {
        let flow = Flow<TestNode>(segue: .a => [.b, .c])
        let graph = NavigationGraph(flow: flow)
        graph.edit(segue: .a => .b)
            .add(trait: .redirect(to: Flow(segue: .a => .c)))
        
        graph.present(node: .b)
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.c))
    }
    
    func testGoForward() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph.forward()
        
        XCTAssertTrue(graph.isPresented(.b))
    }
    
    func testGoForwardMissing() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph.present(node: .b)
        graph.forward()
        
        XCTAssertEqual(graph.activeFlow.segues, [Segue(.a, to: .b)])
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }
    
    func testGoForwardMultiple() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        let flow = Flow<TestNode>(segue: .a => .b => [.c, .d])
        let graph = NavigationGraph(flow: flow)
        graph.present(node: .b)
        graph.forward()
        
        XCTAssertEqual(graph.activeFlow.segues, [Segue(.a, to: .b)])
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }
    
    func testGoForwardMultipleDisabled() {
        let flow = Flow<TestNode>(segue: .a => .b => [.c, .d])
        let graph = NavigationGraph(flow: flow)
        graph.edit(segue: .b => .d)
            .add(trait: .disabled)
        graph.present(node: .b)
        graph.forward()
        
        XCTAssertEqual(graph.activeFlow.segues, [
            Segue(.a, to: .b),
            Segue(.b, to: .c),
        ])
    }
    
    func testGoBack() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph.present(node: .b)
        graph.back()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
    }
    
    func testDismissContext() {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        graph.edit(segue: .a => .b)
            .add(trait: .context)
        graph.present(flow: Flow(segue: .b => .c))
        graph.dismiss()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
    }
    
    func testDismissModal() {
        setenv("HELM_DISABLE_ASSERTIONS", "1", 1)
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        graph.edit(segue: .a => .b)
            .add(trait: .modal)
        graph.present(flow: Flow(segue: .b => .c))
        graph.dismiss()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
        unsetenv("HELM_DISABLE_ASSERTIONS")
    }
    
    func testDismissNoContext() {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        graph.present(flow: Flow(segue: .b => .c))
        graph.dismiss()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.c))
    }
    
    func testIsPresented() {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        
        XCTAssertTrue(graph.isPresented(.a))
    }
    
    func testIsPresentedBinding() {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        graph.present(flow: Flow(segue: .b => .c))
        
        let binding: Binding<Bool> = graph.isPresented(.c)
        XCTAssertTrue(binding.wrappedValue)
        
        binding.wrappedValue = false
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
    }
}
