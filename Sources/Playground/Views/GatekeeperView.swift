//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Foundation
import Fragments
import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 30) {
                TextField("Email", text: $email)
                TextField("Password", text: $password)
            }
            VStack(spacing: 30) {
                Button(action: { nav.present(node: .dashboard) }) {
                    Text("Login")
                }
                .buttonStyle(FillButton())
                Group {
                    Button(action: { nav.present(node: .register) }) {
                        Text("Register")
                            .textCase(.uppercase)
                    }
                    Button(action: { nav.present(node: .forgotPass) }) {
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
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 30) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Email", text: $email)
                TextField("Password", text: $password)
            }
            VStack(spacing: 30) {
                Button(action: { nav.present(node: .dashboard) }) {
                    Text("Register")
                }
                .buttonStyle(FillButton())
                Group {
                    Button(action: { nav.present(node: .login) }) {
                        Text("Login")
                            .textCase(.uppercase)
                    }
                    Button(action: { nav.present(node: .forgotPass) }) {
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
    @EnvironmentObject var nav: NavigationGraph<KeyScreen>

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 30) {
                TextField("Email", text: $email)
            }
            VStack(spacing: 30) {
                Button(action: { nav.present(node: .dashboard) }) {
                    Text("Send me the email")
                }
                .buttonStyle(FillButton())
                Group {
                    Button(action: { nav.present(node: .register) }) {
                        Text("Register")
                            .textCase(.uppercase)
                    }
                    Button(action: { nav.present(node: .login) }) {
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
    @Environment(\.namespace) var namespace

    var body: some View {
        VStack(spacing: 0) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .matchedGeometryEffect(id: "logo", in: namespace)
                .frame(width: 100)
            ZStack {
                Fragment(.login) {
                    LoginView()
                }
                Fragment(.register) {
                    RegisterView()
                }
                Fragment(.forgotPass) {
                    ForgotPasswordView()
                }
            }
            Spacer()
        }
    }
}
