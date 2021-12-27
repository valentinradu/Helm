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
            .clipShape(Capsule())
    }
}

struct BorderButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding()
            .border(.blue, width: 2)
            .foregroundColor(.blue)
            .clipShape(Capsule())
    }
}
