//
//  File.swift
//
//
//  Created by Valentin Radu on 12/12/2021.
//

import Foundation
import Helm
import SwiftUI

enum KeyScreen: Fragment {
    // visible while the app starts
    case splash

    // visible after the app starts, if there's no logged in user
    // it has 3 sub-screens: login, register, forgot password
    case gatekeeper
    case login
    case register
    case forgotPass

    // visible if the logged in user didn't
    // finished the onboarding process yet
    case onboarding
    case onboardingUsername
    case onboardingTutorial
    case onboardingPrivacyPolicy

    // visible if the logged in user
    // finished the onboarding process
    case dashboard

    // library, news and settings are tabs in the dashboard
    case library
    case news
    case settings
    case article

    // start writing a new article: a modal in the dashboard
    case compose

    // edit avatar, bio, username: modals in the settings tab
    case updateAvatar
    case updateBio
    case updateUsername
}

extension Helm where N == KeyScreen {
    static var main: Helm<N> = {
        do {
            var graph = Set<Segue<KeyScreen>>()

            graph.formUnion(Segue.from(.splash,
                                       to: [.onboarding, .gatekeeper, .dashboard]))
            graph.insert(.from(.gatekeeper,
                               to: .login,
                               rule: .hold,
                               auto: true))
            graph.formUnion(Segue.from(.gatekeeper,
                                       to: [.register, .forgotPass],
                                       rule: .hold))
            graph.formUnion(Segue.chain([.login, .register, .forgotPass]))

            return try Helm(nav: graph)
        } catch {
            assertionFailure(error.localizedDescription)
            fatalError()
        }
    }()
}

struct DynamicFragment<V: View>: View {
    @EnvironmentObject var _helm: Helm<KeyScreen>
    private let _screen: KeyScreen
    private let _builder: () -> V
    init(_ screen: KeyScreen, @ViewBuilder builder: @escaping () -> V) {
        _screen = screen
        _builder = builder
    }

    var body: some View {
        if _helm.isPresented(_screen) {
            _builder()
        }
    }
}
