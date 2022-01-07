//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 11/12/2021.
//

import Helm
import SwiftUI

struct RootView: View {
    @StateObject private var _nav: NavigationGraph = .main
    @StateObject private var _state: AppState = .main

    var body: some View {
        ZStack {
            Fragment(.splash) {
                SplashView()
                    .animation(.linear)
            }
            Fragment(.gatekeeper) {
                GatekeeperView()
                    .animation(.linear)
            }
            Fragment(.dashboard) {
                DashboardView()
                    .animation(.linear)
            }
            Fragment(.onboarding) {
                OnboardingView()
                    .animation(.linear)
            }
        }
        .environmentObject(_nav)
        .environmentObject(_state)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                try! _nav.present(node: .dashboard)
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
