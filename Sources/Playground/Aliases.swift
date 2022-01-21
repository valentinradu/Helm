//
//  File.swift
//
//
//  Created by Valentin Radu on 15/01/2022.
//

import Helm

typealias PlaygroundSegue = Segue<PlaygroundFragment>
typealias PlaygroundGraph = Set<PlaygroundSegue>
extension String: Identifiable {
    public var id: String {
        self
    }
}
