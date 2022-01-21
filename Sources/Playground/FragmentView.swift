//
//  File.swift
//
//
//  Created by Valentin Radu on 20/01/2022.
//

import Foundation
import Helm
import SwiftUI

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
