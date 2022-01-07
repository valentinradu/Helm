@testable import Helm
import XCTest

final class SegueTests: XCTestCase {
    func testOneWayConnectors() {
        let flow = Flow<TestNode>(segue: .a => .b)
            .add(segue: .b => .c => .d)
            .add(segue: .d => [.e, .f] => .g)
            .add(segue: [.g, .i] => .j)

        XCTAssertEqual(flow.segues,
                       [
                           Segue(.a, to: .b),
                           Segue(.b, to: .c),
                           Segue(.c, to: .d),
                           Segue(.d, to: .e),
                           Segue(.d, to: .f),
                           Segue(.e, to: .g),
                           Segue(.f, to: .g),
                           Segue(.g, to: .j),
                           Segue(.i, to: .j),
                       ])
    }

    func testTwoWayConnectors() {
        let flow = Flow<TestNode>(segue: .a <=> .b)
            .add(segue: .b <=> .c <=> .d)
            .add(segue: .d <=> [.e, .f] <=> .g)
            .add(segue: [.g, .i] <=> .j)

        XCTAssertEqual(flow.segues,
                       [
                           Segue(.a, to: .b),
                           Segue(.b, to: .a),
                           Segue(.b, to: .c),
                           Segue(.c, to: .b),
                           Segue(.c, to: .d),
                           Segue(.d, to: .c),
                           Segue(.d, to: .e),
                           Segue(.e, to: .d),
                           Segue(.d, to: .f),
                           Segue(.f, to: .d),
                           Segue(.e, to: .g),
                           Segue(.g, to: .e),
                           Segue(.f, to: .g),
                           Segue(.g, to: .f),
                           Segue(.g, to: .j),
                           Segue(.j, to: .g),
                           Segue(.i, to: .j),
                           Segue(.j, to: .i),
                       ])
    }

    func testAddTrait() throws {
        let flow = Flow<TestNode>(segue: .a => [.b, .c])
        let graph = try NavigationGraph(flow: flow)
        try graph
            .edit(segue: .a => [.b, .c])
            .add(trait: .auto)
            .add(trait: .auto)
            .add(trait: .context)
        XCTAssertEqual(graph.traits,
                       [
                           Segue(.a, to: .b): [.auto, .context],
                           Segue(.a, to: .c): [.auto, .context],
                       ])
    }

    func testRemoveTrait() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = try NavigationGraph(flow: flow)
        try graph
            .edit(segue: .a => .b)
            .add(trait: .context)
            .remove(trait: .context)
        XCTAssertEqual(graph.traits, [:])
    }

    func testClearTrait() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = try NavigationGraph(flow: flow)
        try graph
            .edit(segue: .a => .b)
            .add(trait: .context)
            .clear()
        XCTAssertEqual(graph.traits, [:])
    }

    func testFilterTrait() throws {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = try NavigationGraph(flow: flow)
        try graph
            .edit(segue: .a => .b)
            .add(trait: .context)
            .add(trait: .auto)
            .filter { $0 == .auto }
        XCTAssertEqual(graph.traits, [Segue(.a, to: .b): [.context]])
    }
}
