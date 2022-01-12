//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Foundation
import Helm
import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @EnvironmentObject var _helm: Helm<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 30) {
                TextField("Email", text: $email)
                TextField("Password", text: $password)
            }
            VStack(spacing: 30) {
                LargeButton(action: { _helm.present(fragment: .dashboard) }) {
                    Text("Login")
                }
                .buttonStyle(FillButton())
                Group {
                    LargeButton(action: { _helm.present(fragment: .register) }) {
                        Text("Register")
                            .textCase(.uppercase)
                    }
                    LargeButton(action: { _helm.present(fragment: .forgotPass) }) {
                        Text("Forgot password")
                    }
                }
                .buttonStyle(BorderButton())
            }
            .textCase(.uppercase)
        }
    }
}

struct RegisterView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @EnvironmentObject var _helm: Helm<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 30) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Email", text: $email)
                TextField("Password", text: $password)
            }
            VStack(spacing: 30) {
                LargeButton(action: { _helm.present(fragment: .dashboard) }) {
                    Text("Register")
                }
                .buttonStyle(FillButton())
                Group {
                    LargeButton(action: { _helm.present(fragment: .login) }) {
                        Text("Login")
                            .textCase(.uppercase)
                    }
                    LargeButton(action: { _helm.present(fragment: .forgotPass) }) {
                        Text("Forgot password")
                    }
                }
                .buttonStyle(BorderButton())
            }
            .textCase(.uppercase)
        }
    }
}

struct ForgotPasswordView: View {
    @State var email: String = ""
    @EnvironmentObject var _helm: Helm<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 30) {
                TextField("Email", text: $email)
            }
            VStack(spacing: 30) {
                LargeButton(action: { _helm.present(fragment: .dashboard) }) {
                    Text("Send me the email")
                }
                .buttonStyle(FillButton())
                Group {
                    LargeButton(action: { _helm.present(fragment: .register) }) {
                        Text("Register")
                            .textCase(.uppercase)
                    }
                    LargeButton(action: { _helm.present(fragment: .login) }) {
                        Text("Login")
                    }
                }
                .buttonStyle(BorderButton())
            }
            .textCase(.uppercase)
        }
    }
}

struct GatekeeperView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("logo")
            ZStack {
                DynamicFragment(.login) {
                    LoginView()
                }
                DynamicFragment(.register) {
                    RegisterView()
                }
                DynamicFragment(.forgotPass) {
                    ForgotPasswordView()
                }
            }
        }
        .padding(40)
    }
}
