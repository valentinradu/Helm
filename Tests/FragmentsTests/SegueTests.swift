@testable import Fragments
import XCTest

final class SegueTests: XCTestCase {
    func testConnectors() throws {
        var flow = Flow<TestNode>()
        flow.add(segue: .a => .b => .c)
        flow.add(segue: .b => .c => [.d, .e] => .f)

        XCTAssertEqual(flow.segues,
                       [
                           Segue(.a, to: .b),
                           Segue(.b, to: .c),
                           Segue(.c, to: .d),
                           Segue(.c, to: .e),
                           Segue(.e, to: .f),
                           Segue(.d, to: .f),
                       ])
    }
}
