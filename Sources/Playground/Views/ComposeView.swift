//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Helm
import SwiftUI

struct ComposeView: View {
    @State private var _content: String = ""
    @EnvironmentObject private var _helm: Helm<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            HStack {
                Spacer()
                LargeButton(action: { _helm.dismiss() }) {
                    Image(systemName: "xmark")
                }
            }
            VStack(spacing: 20) {
                Text("Write your story")
                    .font(.headline)
                TextEditor(text: $_content)
                LargeButton(action: { _helm.dismiss() }) {
                    Text("Publish")
                }
                .buttonStyle(FillButton())
            }
        }
    }
}
