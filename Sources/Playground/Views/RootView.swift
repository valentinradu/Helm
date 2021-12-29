//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 11/12/2021.
//

import Helm
import SwiftUI

struct NamespaceEnvironmentKey: EnvironmentKey {
    static var defaultValue: Namespace.ID = Namespace().wrappedValue
}

extension EnvironmentValues {
    var namespace: Namespace.ID {
        get { self[NamespaceEnvironmentKey.self] }
        set { self[NamespaceEnvironmentKey.self] = newValue }
    }
}

extension View {
    func namespace(_ value: Namespace.ID) -> some View {
        environment(\.namespace, value)
    }
}

struct RootView: View {
    @Namespace private var namespace

    var body: some View {
        ZStack {
            Fragment(.splash) {
                SplashView()
            }
            Fragment(.dashboard) {
                DashboardView()
            }
            Fragment(.onboarding) {
                OnboardingView()
            }
        }
        .environmentObject(NavigationGraph.main)
        .environmentObject(AppState.main)
        .namespace(namespace)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
    }
}
