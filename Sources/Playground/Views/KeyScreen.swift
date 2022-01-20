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
            let edges = Set<DirectedEdge<KeyScreen>>()
                .union(.splash => [.gatekeeper, .onboarding, .dashboard])
                .union(.gatekeeper => [.onboarding, .dashboard])
                .union([.onboarding => .dashboard])
                .union(.gatekeeper => [.login, .register, .forgotPass])
                .union(.login => .register => .forgotPass => .login)
                .union(.login => .forgotPass => .register => .login)
                .union(.onboarding => .onboardingUsername => .onboardingTutorial)
                .union(.dashboard => [.library, .news, .settings, .compose])
                .union(.library => .news => .settings => .library)
                .union(.library => .settings => .news => .library)
                .union(.settings => [.updateAvatar, .updateBio, .updateUsername])

            let segues = Set(edges.map { (edge: DirectedEdge<KeyScreen>) -> Segue<KeyScreen> in
                switch edge {
                case .gatekeeper => .login:
                    return Segue(edge, style: .hold, auto: true)
                case .gatekeeper => .register, .gatekeeper => .forgotPass:
                    return Segue(edge, style: .hold)
                case .dashboard => .news:
                    return Segue(edge, style: .hold, auto: true)
                case .dashboard => .compose:
                    return Segue(edge, style: .hold, dismissable: true)
                case .dashboard => .library:
                    return Segue(edge, style: .hold)
                default:
                    return Segue(edge)
                }
            })
            return try Helm(nav: segues,
                            path: [
                                PathEdge(.splash => .gatekeeper),
                                PathEdge(.gatekeeper => .register),
                            ])
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
