//
//  File.swift
//
//
//  Created by Valentin Radu on 13/01/2022.
//

import Foundation
import SwiftUI

@testable import Helm
import XCTest

class SegueTests: XCTestCase {
    func testFromOneToOne() {
        let segue: Segue<TestNode> = .from(.a,
                                           to: .b,
                                           rule: .hold,
                                           dismissable: true,
                                           auto: true)
        XCTAssertEqual(segue, Segue(from: .a,
                                    to: .b,
                                    rule: .hold,
                                    dismissable: true,
                                    auto: true))
    }

    func testFromOneToMany() {
        let segues: Set<Segue<TestNode>> = Segue.from(.a,
                                                      to: [.b, .c],
                                                      rule: .hold,
                                                      dismissable: true,
                                                      auto: true)
        XCTAssertEqual(segues,
                       [
                           Segue(from: .a,
                                 to: .b,
                                 rule: .hold,
                                 dismissable: true,
                                 auto: true),
                           Segue(from: .a,
                                 to: .c,
                                 rule: .hold,
                                 dismissable: true,
                                 auto: true),
                       ])
    }

    func testChain() {
        let emptySegues: Set<Segue<TestNode>> = Segue.chain([],
                                                            rule: .hold,
                                                            dismissable: true,
                                                            auto: true)

        XCTAssertEqual(emptySegues, [])

        let singleSegue: Set<Segue<TestNode>> = Segue.chain([.a],
                                                            rule: .hold,
                                                            dismissable: true,
                                                            auto: true)

        XCTAssertEqual(singleSegue, [Segue(from: .a,
                                           to: .a,
                                           rule: .hold,
                                           dismissable: true,
                                           auto: true)])

        let chainSegues: Set<Segue<TestNode>> = Segue.chain([.a, .b, .c],
                                                            rule: .hold,
                                                            dismissable: true,
                                                            auto: true)

        XCTAssertEqual(chainSegues, [Segue(from: .a,
                                           to: .b,
                                           rule: .hold,
                                           dismissable: true,
                                           auto: true),
                                     Segue(from: .b,
                                           to: .c,
                                           rule: .hold,
                                           dismissable: true,
                                           auto: true)])
    }
}
