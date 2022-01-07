//
//  File.swift
//
//
//  Created by Valentin Radu on 31/12/2021.
//

import Foundation

public enum HelmError<N: Node>: Error {}

extension HelmError: LocalizedError {
    public var errorDescription: String? {
        ""
    }
}
