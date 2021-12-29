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
                           Segue(.f, to: .g),
                           Segue(.e, to: .g),
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
                           Segue(.f, to: .g),
                           Segue(.g, to: .f),
                           Segue(.e, to: .g),
                           Segue(.g, to: .e),
                           Segue(.g, to: .j),
                           Segue(.j, to: .g),
                           Segue(.i, to: .j),
                           Segue(.j, to: .i),
                       ])
    }

    func testAddTrait() {
        let flow = Flow<TestNode>(segue: .a => [.b, .c])
        let graph = NavigationGraph(flow: flow)
        graph
            .edit(segue: .a => [.b, .c])
            .add(trait: .cover)
            .add(trait: .cover)
            .add(trait: .context)
        XCTAssertEqual(graph.traits,
                       [
                           Segue(.a, to: .b): [.cover, .context],
                           Segue(.a, to: .c): [.cover, .context],
                       ])
    }

    func testRemoveTrait() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph
            .edit(segue: .a => .b)
            .add(trait: .modal)
            .remove(trait: .modal)
        XCTAssertEqual(graph.traits, [:])
    }

    func testClearTrait() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph
            .edit(segue: .a => .b)
            .add(trait: .modal)
            .clear()
        XCTAssertEqual(graph.traits, [:])
    }

    func testFilterTrait() {
        let flow = Flow<TestNode>(segue: .a => .b)
        let graph = NavigationGraph(flow: flow)
        graph
            .edit(segue: .a => .b)
            .add(trait: .modal)
            .add(trait: .next)
            .filter { $0 == .next }
        XCTAssertEqual(graph.traits, [Segue(.a, to: .b): [.next]])
    }
}
