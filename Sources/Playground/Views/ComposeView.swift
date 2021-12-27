//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Fragments
import SwiftUI

struct ComposeView: View {
    @State private var content: String = ""
    @EnvironmentObject private var nav: NavigationGraph<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            HStack {
                Spacer()
                Button(action: { nav.dismiss() }) {
                    Image(systemName: "xmark")
                }
            }
            VStack(spacing: 20) {
                Text("Write your story")
                    .font(.headline)
                TextEditor(text: $content)
                Button(action: { nav.dismiss() }) {
                    Text("Publish")
                }
                .buttonStyle(FillButton())
            }
        }
    }
}
