//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Helm
import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var _helm: Helm<KeyScreen>

    var body: some View {
        VStack(alignment: .center) {
            Image("logo", bundle: .module)
        }
    }
}
