//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 11/12/2021.
//

import Helm
import SwiftUI

extension String: Identifiable {
    public var id: String {
        self
    }
}

struct RootView: View {
    @StateObject private var _helm: Helm = .main
    @StateObject private var _state: AppState = .main
    @State private var _lastError: String? = nil

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
            if let error = _lastError {
                VStack {
                    Spacer()
                    Text(verbatim: error)
                        .padding()
                        .background(Color.gray)
                    Spacer()
                }
            }
        }
        .environmentObject(_helm)
        .environmentObject(_state)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                _helm.present(fragment: .dashboard)
            }
        }
        .onReceive(_helm.$errors) {
            guard let lastError = $0.last else {
                return
            }
            _lastError = String(describing: lastError)
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
