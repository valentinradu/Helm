//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Helm
import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var _state: AppState
    @EnvironmentObject private var _helm: Helm<KeyScreen>

    var body: some View {
        NavigationView {
            List(_state.articles) {
                NavigationLink(destination: ArticleView(),
                               isActive: _helm.isPresented(.article)) {
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
    @EnvironmentObject private var _state: AppState

    var body: some View {
        NavigationView {
            List(_state.news) {
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
    @EnvironmentObject private var _helm: Helm<KeyScreen>

    var body: some View {
        VStack {
            HStack {
                Spacer()
                LargeButton(action: { _helm.present(fragment: .compose) }) {
                    Image(systemName: "plus.square.on.square")
                }
            }
            TabView(selection: _helm.pickPresented([.library, .news, .settings])) {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "book.closed")
                    }
                    .tag(Optional.some(KeyScreen.library))
                NewsView()
                    .tabItem {
                        Label("News", systemImage: "newspaper")
                    }
                    .tag(Optional.some(KeyScreen.news))
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(Optional.some(KeyScreen.settings))
            }
        }
        .sheet(isPresented: _helm.isPresented(.compose)) {
            ComposeView()
        }
    }
}
