//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import SwiftUI

struct FillButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}

struct BorderButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .foregroundColor(.blue)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.blue, lineWidth: 2)
            )
    }
}

struct LargeButton<V: View>: View {
    private let _action: () -> Void
    private let _content: () -> V
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> V) {
        _action = action
        _content = content
    }

    var body: some View {
        Button(action: _action) {
            HStack {
                Spacer()
                _content()
                Spacer()
            }
        }
    }
}
