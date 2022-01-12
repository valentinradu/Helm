//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 11/12/2021.
//

import Helm
import SwiftUI

struct RootView: View {
    @StateObject private var _helm: Helm = .main
    @StateObject private var _state: AppState = .main

    var body: some View {
        ZStack {
            DynamicFragment(.splash) {
                SplashView()
                    .animation(.linear)
            }
            DynamicFragment(.gatekeeper) {
                GatekeeperView()
                    .animation(.linear)
            }
            DynamicFragment(.dashboard) {
                DashboardView()
                    .animation(.linear)
            }
            DynamicFragment(.onboarding) {
                OnboardingView()
                    .animation(.linear)
            }
        }
        .environmentObject(_helm)
        .environmentObject(_state)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                _helm.present(fragment: .dashboard)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
    }
}
