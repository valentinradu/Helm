//
//  File.swift
//
//
//  Created by Valentin Radu on 12/12/2021.
//

import Foundation
import Fragments

enum KeyScreen: Node {
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

    // start writing a new article: a modal in the dashboard
    case compose

    // edit avatar, bio, username: modals in the settings tab
    case updateAvatar
    case updateBio
    case updateUsername
}

extension Flow where N == KeyScreen {
    static var main: NavigationGraph<N> = {
        let flow: Flow<N> = .init()
            // from `.splash` (initial loading screen) to any of the
            // `.gatekeeper`, `.onboarding`, `.dashboard` screens,
            // depending on the app state (user logged in, onboarded etc)
            .add(segue: KeyScreen.splash => [KeyScreen.gatekeeper, KeyScreen.onboarding, KeyScreen.dashboard])
            // from `.gatekeeper` (the authentication-related screen),
            // to any of the `.login`, `.register` or `.forgotPass`, depending
            // on user navigation. We'll later on set the default screen to `.login`
            // using a redirect segue trait
            .add(segue: KeyScreen.gatekeeper => [KeyScreen.login, KeyScreen.register, KeyScreen.forgotPass])
            // like in many authentication screens, we can freely navigate between
            // `.login`, `.register` and `.forgotPass` (from any to any)
            .add(segue: KeyScreen.login <=> KeyScreen.register <=> KeyScreen.forgotPass <=> KeyScreen.login)
            // we can freely navigate between the onboarding screens, however, we can't return to the root `.onboarding` parent screen
            .add(segue: KeyScreen.onboarding => KeyScreen.onboardingUsername <=> KeyScreen.onboardingTutorial <=> KeyScreen.onboardingPrivacyPolicy => KeyScreen.dashboard)
            // when logging out, we move from `.dashboard` back to the `.gatekeeper`
            .add(segue: KeyScreen.dashboard => KeyScreen.gatekeeper)
            // from `.dashboard` we can access any of it's tabs:
            // `.library`, `.news`, `.settings`
            .add(segue: KeyScreen.dashboard => [KeyScreen.library, KeyScreen.news, KeyScreen.settings])
            // but also, since this is a tabbed navigation,
            // we can reach any of the screens from the others
            .add(segue: KeyScreen.library <=> KeyScreen.news <=> KeyScreen.settings <=> KeyScreen.library)
            // we can reach the compose modal from the dashboard
            .add(segue: KeyScreen.dashboard <=> KeyScreen.compose)
            // settings is a list, you can navigate from the
            // root to any of the items and back
            .add(segue: KeyScreen.settings <=> [KeyScreen.updateAvatar, KeyScreen.updateBio, KeyScreen.updateUsername])
            // some segues require additional fine tuning;
            // although segue traits are mutable and can be added at any
            // time, however, we start with some to define the
            // initial
            // we initially disable the navigation to the dashboard and onboarding;
            // these are available only when the user is logged in
//            .addTrait(.redirect(to: Path(.gatekeeper)), segue: Segue(.splash, to: .onboarding))
//            .addTrait(.redirect(to: Path(.gatekeeper)), segue: Segue(.splash, to: .dashboard))
            // the compose screen is a modal
//            .addTrait(.modal, segue: Segue(.dashboard, to: .compose))
            // the onboarding screens can be navigating in a relative way using `.next()` and `.prev()` commands
//            .addTrait(.next, segue: Segue(.onboardingUsername, to: .onboardingTutorial))
//            .addTrait(.next, segue: Segue(.onboardingTutorial, to: .onboardingPrivacyPolicy))
//            .addTrait(.next, segue: Segue(.onboardingPrivacyPolicy, to: .dashboard))
//            .addTrait(.prev, segue: Segue(.onboardingPrivacyPolicy, to: .onboardingTutorial))
//            .addTrait(.prev, segue: Segue(.onboardingTutorial, to: .onboardingUsername))
            // the root onboarding screen forwards to the first onboarding screen (username)
//            .addTrait(.redirect(to: Path(.onboardingUsername)), segue: Segue(.))
            

        return NavigationGraph(flow: flow)
    }()
}
