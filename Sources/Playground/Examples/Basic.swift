//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 21/01/2022.
//

import Helm
import SwiftUI

/// This is a helper I often use to avoid `if`s.
/// It's optional.
struct FragmentView<V: View>: View {
    @EnvironmentObject private var _helm: Helm<PlaygroundFragment>
    private let _fragment: PlaygroundFragment
    private let _builder: () -> V
    init(_ fragment: PlaygroundFragment, @ViewBuilder builder: @escaping () -> V) {
        _fragment = fragment
        _builder = builder
    }

    var body: some View {
        if _helm.isPresented(_fragment) {
            _builder()
        }
    }
}

struct BasicExample: View {
    @EnvironmentObject private var _helm: Helm<PlaygroundFragment>

    var body: some View {
        HStack {
            FragmentView(.b) {
                Rectangle()
                    .frame(width: 75)
                    .transition(.move(edge: .leading))
            }
            Spacer()
            Toggle("Toggle menu",
                   isOn: _helm.isPresented(.b))
                .padding()
                .fixedSize()
            if let error = _helm.errors.last {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .animation(.default, value: _helm.isPresented(.b))
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
    }
}

struct BasicExample_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @StateObject private var _helm: Helm = try! Helm(nav: [
            PlaygroundSegue(.a => .b).makeDismissable()
        ])

        var body: some View {
            BasicExample()
                .environmentObject(_helm)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
