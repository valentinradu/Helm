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
    func testEditExistingSegue() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        let op = try graph.edit(segue: .a => .b)
        XCTAssertEqual(op.segues, [Segue(.a, to: .b)])
    }

    func testEditMissingSegue() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        let segue = Segue<TestNode>(.b, to: .c)
        let error = HelmError<TestNode>.missingSegues(value: [segue])
            
        XCTAssertThrowsError(
            try graph.edit(segue: segue),
            error.debugDescription
        )
    }

    func testPresentExclusively() throws {
        let flow = Flow<TestNode>(segue: .a => [.b, .c, .d])
            .add(segue: .b => .e)
        let graph = NavigationGraph(flow: flow)
        
        try graph.present(flow: Flow(segue: .b => .e))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.e))
        XCTAssertFalse(graph.isPresented(.c))
        XCTAssertFalse(graph.isPresented(.d))
        
        try graph.present(node: .c)
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.e))
        XCTAssertTrue(graph.isPresented(.c))
        XCTAssertFalse(graph.isPresented(.d))
    }
    
    func testPresentInclusively() throws {
        let flow = Flow<TestNode>(segue: .a => [.b, .c, .d])
            .add(segue: .b => .e)
        let graph = NavigationGraph(flow: flow)
        
        try graph.edit(segue: .a => .b)
            .add(trait: .modal)
        try graph.edit(segue: .a => .c)
            .add(trait: .cover)
        
        try graph.present(node: .d)
        try graph.present(flow: Flow(segue: .b => .e))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.e))
        XCTAssertFalse(graph.isPresented(.c))
        XCTAssertTrue(graph.isPresented(.d))
        
        try graph.present(node: .c)
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.e))
        XCTAssertTrue(graph.isPresented(.c))
        XCTAssertTrue(graph.isPresented(.d))
    }
    
    func testUnreachablePresentedNode() {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        let error = HelmError<TestNode>.inwardIsolated(node: .c)
        
        XCTAssertThrowsError(
            try graph.present(node: .c),
            error.debugDescription
        )
    }
    
    func testUnreachablePresentedFlow() {
        let flow = Flow<TestNode>(segue: .a => .b => .c => .d)
        let graph = NavigationGraph(flow: flow)
        let error = HelmError<TestNode>.inwardIsolated(node: .c)
        
        XCTAssertThrowsError(
            try graph.present(node: .c),
            error.debugDescription
        )
    }
    
    func testAutoForward() throws {
        let flow = Flow<TestNode>(segue: .a => [.b, .c])
        let graph = NavigationGraph(flow: flow)
        try graph.edit(segue: .a => .b)
            .add(trait: .redirect(to: Flow(segue: .a => .c)))
        
        try graph.present(node: .b)
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.c))
    }
    
    func testGoForward() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        try graph.forward()
        
        XCTAssertTrue(graph.isPresented(.b))
    }
    
    func testGoForwardMissing() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        let error = HelmError<TestNode>.forwardIsolated(node: .b)
        try graph.present(node: .b)
        
        XCTAssertThrowsError(
            try graph.forward(),
            error.debugDescription
        )
    }
    
    func testGoForwardMultiple() throws {
        let flow = Flow<TestNode>(segue: .a => .b => [.c, .d])
        let graph = NavigationGraph(flow: flow)
        let error = HelmError<TestNode>.forwardAmbigous(
            node: .b,
            segues: [
                Segue(.b, to: .c),
                Segue(.b, to: .d),
            ]
        )
        try graph.present(node: .b)
        
        XCTAssertThrowsError(
            try graph.forward(),
            error.debugDescription
        )
    }
    
    func testGoForwardMultipleDisabled() throws {
        let flow = Flow<TestNode>(segue: .a => .b => [.c, .d])
        let graph = NavigationGraph(flow: flow)
        try graph.edit(segue: .b => .d)
            .add(trait: .disabled)
        try graph.present(node: .b)
        try graph.forward()
        
        XCTAssertEqual(graph.pathFlow.segues, [
            Segue(.a, to: .b),
            Segue(.b, to: .c),
        ])
    }
    
    func testGoBack() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        try graph.present(node: .b)
        try graph.back()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
    }
    
    func testDismissContext() throws {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        try graph.edit(segue: .a => .b)
            .add(trait: .context)
        try graph.present(flow: Flow(segue: .b => .c))
        try graph.dismiss()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
    }
    
    func testDismissModal() throws {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        try graph.edit(segue: .a => .b)
            .add(trait: .modal)
        try graph.present(flow: Flow(segue: .b => .c))
        try graph.dismiss()
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertFalse(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
    }
    
    func testDismissNoContext() throws {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        let error = HelmError<TestNode>.noContext(from: .c)
        try graph.present(flow: Flow(segue: .b => .c))
        
        XCTAssertThrowsError(
            try graph.dismiss(),
            error.debugDescription
        )
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertTrue(graph.isPresented(.c))
    }
    
    func testIsPresented() {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        
        XCTAssertTrue(graph.isPresented(.a))
    }
    
    func testIsPresentedBinding() throws {
        let flow = Flow<TestNode>(segue: .a => .b => .c)
        let graph = NavigationGraph(flow: flow)
        try graph.present(flow: Flow(segue: .b => .c))
        
        let binding: Binding<Bool> = graph.isPresented(.c)
        XCTAssertTrue(binding.wrappedValue)
        
        binding.wrappedValue = false
        
        XCTAssertTrue(graph.isPresented(.a))
        XCTAssertTrue(graph.isPresented(.b))
        XCTAssertFalse(graph.isPresented(.c))
    }
}
