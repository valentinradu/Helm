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
            let graph = try Helm(nav: [])
            
//            // from `.splash` (initial loading screen) to any of the
//            // `.gatekeeper`, `.onboarding`, `.dashboard` screens,
//            // depending on the app state (user logged in, onboarded etc)
//            let flow = Flow<KeyScreen>(segue: .splash => [.gatekeeper, .onboarding, .dashboard])
//                // from `.gatekeeper` (the authentication-related screen),
//                // to any of the `.login`, `.register` or `.forgotPass`, depending
//                // on user navigation. We'll later on set the default screen to `.login`
//                // using a redirect segue trait
//                .add(segue: .gatekeeper => [.login, .register, .forgotPass])
//                // like in many authentication screens, we can freely navigate between
//                // `.login`, `.register` and `.forgotPass` (from any to any)
//                .add(segue: .login <=> .register <=> .forgotPass <=> .login)
//                // we can freely navigate between the onboarding screens, however, we can't return to the root `.onboarding` parent screen
//                .add(segue: .onboarding => .onboardingUsername <=> .onboardingTutorial <=> .onboardingPrivacyPolicy => .dashboard)
//                // when logging out, we move from `.dashboard` back to the `.gatekeeper`
//                .add(segue: .dashboard => .gatekeeper)
//                // from `.dashboard` we can access any of it's tabs:
//                // `.library`, `.news`, `.settings`
//                .add(segue: .dashboard => [.library, .news, .settings])
//                // but also, since this is a tabbed navigation,
//                // we can reach any of the screens from the others
//                .add(segue: .library <=> .news <=> .settings <=> .library)
//                // also, you can navigate to the article details and back
//                .add(segue: .library <=> .article)
//                // we can reach the compose modal from the dashboard
//                .add(segue: .dashboard <=> .compose)
//                // settings is a list, you can navigate from the
//                // root to any of the items and back
//                .add(segue: .settings <=> [.updateAvatar, .updateBio, .updateUsername])
//
            return graph
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
