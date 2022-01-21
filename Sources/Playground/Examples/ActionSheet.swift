//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Helm
import SwiftUI

struct ActionSheetExample: View {
    @EnvironmentObject private var _helm: Helm<PlaygroundFragment>

    var body: some View {
        VStack {
            Button(action: { _helm.present(fragment: .b) }) {
                Text("Open sheet")
            }
            .sheet(isPresented: _helm.isPresented(.b)) {
                Text("Hello there!")
            }
            if let error = _helm.errors.last {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
    }
}

struct ActionSheetExample_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @StateObject private var _helm: Helm = try! Helm(nav: [
            PlaygroundSegue(.a => .b).makeDismissable()
        ])

        var body: some View {
            ActionSheetExample()
                .environmentObject(_helm)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
