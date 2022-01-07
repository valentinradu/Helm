//
//  File.swift
//
//
//  Created by Valentin Radu on 04/01/2022.
//

import Foundation

public enum OptionalError: Error {
    case failedToUnwrap
}

extension Optional {
    func unwrapOr(error: Error) throws -> Wrapped {
        if let value = self {
            return value
        }
        else {
            throw error
        }
    }

    func unwrap() throws -> Wrapped {
        try unwrapOr(error: OptionalError.failedToUnwrap)
    }
}
