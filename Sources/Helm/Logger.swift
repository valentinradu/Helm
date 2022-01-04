//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Foundation
import os

let logger = Logger(subsystem: "com.valentinradu.helm", category: "ui")

func reportError(_ message: @autoclosure () -> String,
                 file: StaticString = #file,
                 line: UInt = #line)
{
    #if DEBUG && !HELM_DISABLE_ASSERTIONS
//    assertionFailure(message(), file: file, line: line)
    #else
    let messageString = message()
    logger.fault("\(messageString) at \(file):\(line)")
    #endif
}
