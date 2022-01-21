//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Helm
import SwiftUI

struct TabViewExample: View {
    @EnvironmentObject private var _helm: Helm<PlaygroundFragment>

    var body: some View {
        VStack {
            if let error = _helm.errors.last {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
            TabView(selection: _helm.pickPresented([.b, .c, .d])) {
                Text("Users view")
                    .tabItem {
                        Image(systemName: "person.circle.fill")
                        Text("Users")
                    }
                    .tag(Optional.some(PlaygroundFragment.b))
                Text("Clips view")
                    .tabItem {
                        Image(systemName: "paperclip.circle.fill")
                        Text("Clips")
                    }
                    .tag(Optional.some(PlaygroundFragment.c))
                Text("More view")
                    .tabItem {
                        Image(systemName: "ellipsis")
                        Text("More")
                    }
                    .tag(Optional.some(PlaygroundFragment.d))
            }
        }
    }
}

struct TabViewExample_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        private static var segues: Set<PlaygroundSegue> {
            let entry: PlaygroundEdge = .a => .c
            let forward: Set<PlaygroundEdge> = .b => .c => .d => .b
            let backward: Set<PlaygroundEdge> = .b => .d => .c => .b

            return Set(
                [PlaygroundSegue(entry).makeAuto()]
                    + forward.map { Segue($0) }
                    + backward.map { Segue($0) }
            )
        }

        @StateObject private var _helm: Helm = try! Helm(nav: segues)

        var body: some View {
            TabViewExample()
                .environmentObject(_helm)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
