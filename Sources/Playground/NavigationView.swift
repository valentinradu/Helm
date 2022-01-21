//
//  File.swift
//
//
//  Created by Valentin Radu on 20/01/2022.
//

import Helm
import SwiftUI

struct ContenView: View {
    @EnvironmentObject private var _helm: Helm<PlaygroundFragment>

    let title: String
    var body: some View {
        Text("This is \(title)")
            .navigationBarBackButtonHidden(!_helm.canDismiss())
    }
}

struct NavigationViewExample: View {
    @EnvironmentObject private var _helm: Helm<PlaygroundFragment>

    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section(
                        content: {
                            ForEach(["Porto", "London", "Barcelona"]) { city in
                                NavigationLink(destination: ContenView(title: city),
                                               isActive: _helm.isPresented(.b, id: city)) {
                                    Text(city)
                                }
                            }
                            Button(action: { _helm.present(fragment: .b, id: "London") }) {
                                Text("Select London")
                            }
                        },
                        footer: {
                            if let error = _helm.errors.last {
                                Section {
                                    Text("Error: \(error.localizedDescription)")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

struct NavigationViewExample_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @StateObject private var _helm: Helm = try! Helm(nav: [
            PlaygroundSegue(.a => .b).makeDismissable()
        ])

        var body: some View {
            NavigationViewExample()
                .environmentObject(_helm)
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
