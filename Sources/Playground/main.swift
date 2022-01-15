//
//  File.swift
//
//
//  Created by Valentin Radu on 15/01/2022.
//

import SwiftUI

@main
struct PlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .frame(minWidth: 420,
                       minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
