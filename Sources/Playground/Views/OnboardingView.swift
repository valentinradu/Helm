//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Fragments
import SwiftUI

struct OnboardingUsernameView: View {
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>
    @State private var username: String = ""

    var body: some View {
        VStack(spacing: 60) {
            TextField("Username", text: $username)
            Button(action: { nav.next() }) {
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
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>
    var body: some View {
        VStack(spacing: 60) {
            Text("Some possible long tutorial")
            Button(action: { nav.next() }) {
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
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>
    var body: some View {
        VStack(spacing: 60) {
            Text("Full terms and conditions")
            Button(action: { nav.next() }) {
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
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>

    var body: some View {
        NavigationView {
            OnboardingUsernameView()
            NavigationLink(destination: OnboardingTutorialView(),
                           isActive: nav.isPresented(.onboardingTutorial)) {
                EmptyView()
            }
            NavigationLink(destination: OnboardingTermsView(),
                           isActive: nav.isPresented(.onboardingPrivacyPolicy)) {
                EmptyView()
            }
        }
    }
}
