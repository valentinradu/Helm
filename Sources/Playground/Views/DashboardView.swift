//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Helm
import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var nav: NavigationGraph<KeyScreen>

    var body: some View {
        NavigationView {
            List(state.articles) {
                NavigationLink(destination: ArticleView(),
                               isActive: nav.isPresented(.article)) {
                    EmptyView()
                }
                LibraryItemView(title: $0.title, desc: $0.desc)
            }
        }
    }
}

struct LibraryItemView: View {
    let title: String
    let desc: String

    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
            Text(desc)
                .font(.title3)
        }
    }
}

struct NewsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationView {
            List(state.news) {
                NewsItemView(title: $0.title, content: $0.content)
            }
        }
    }
}

struct NewsItemView: View {
    let title: String
    let content: String

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "photo.fill")
                Text(title)
                    .font(.title2)
            }
            Text(content)
                .font(.title3)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            Text("Settings")
        }
    }
}

struct ArticleView: View {
    var body: some View {
        ZStack {
            Text("An article")
        }
    }
}

struct DashboardView: View {
    @State private var selection: Int = 0
    @EnvironmentObject private var nav: NavigationGraph<KeyScreen>

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { nav.present(node: .compose) }) {
                    Image(systemName: "plus.square.on.square")
                }
            }
            TabView(selection: $selection) {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "book.closed")
                    }
                NewsView()
                    .tabItem {
                        Label("News", systemImage: "newspaper")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        }
        .sheet(isPresented: nav.isPresented(.compose)) {
            ComposeView()
        }
        .onChange(of: selection) {
            let screens: [KeyScreen] = [.library, .news, .settings]
            nav.present(node: screens[$0])
        }
    }
}
