//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Helm
import SwiftUI

struct SplashView: View {
    @Environment(\.namespace) private var _namespace
    @EnvironmentObject private var _nav: NavigationGraph<KeyScreen>

    var body: some View {
        ZStack(alignment: .center) {
            Image("logo", bundle: .module)
                .matchedGeometryEffect(id: "logo", in: _namespace)
        }
    }
}
