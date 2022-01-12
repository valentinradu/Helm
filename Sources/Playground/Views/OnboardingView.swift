//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Helm
import SwiftUI

struct OnboardingUsernameView: View {
    @EnvironmentObject private var _helm: Helm<KeyScreen>
    @State private var _username: String = ""

    var body: some View {
        VStack(spacing: 60) {
            TextField("Username", text: $_username)
            LargeButton(action: { _helm.forward() }) {
                HStack {
                    Text("Next")
                    Image(systemName: "arrow.forward.circle")
                }
            }
        }
        .navigationTitle("Pick a username")
    }
}

struct OnboardingTutorialView: View {
    @EnvironmentObject var _helm: Helm<KeyScreen>
    var body: some View {
        VStack(spacing: 60) {
            Text("Some possible long tutorial")
            LargeButton(action: { _helm.forward() }) {
                HStack {
                    Text("Next")
                    Image(systemName: "arrow.forward.circle")
                }
            }
        }
        .navigationTitle("Tutorial")
    }
}

struct OnboardingTermsView: View {
    @EnvironmentObject var _helm: Helm<KeyScreen>
    var body: some View {
        VStack(spacing: 60) {
            Text("Full terms and conditions")
            LargeButton(action: { _helm.forward() }) {
                HStack {
                    Text("Finish")
                    Image(systemName: "checkmark.circle")
                }
            }
        }
        .navigationTitle("Terms")
    }
}

struct OnboardingView: View {
    @EnvironmentObject var _helm: Helm<KeyScreen>

    var body: some View {
        NavigationView {
            OnboardingUsernameView()
            NavigationLink(destination: OnboardingTutorialView(),
                           isActive: _helm.isPresented(.onboardingTutorial)) {
                EmptyView()
            }
            NavigationLink(destination: OnboardingTermsView(),
                           isActive: _helm.isPresented(.onboardingPrivacyPolicy)) {
                EmptyView()
            }
        }
    }
}
