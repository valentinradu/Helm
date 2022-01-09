//
//  File.swift
//
//
//  Created by Valentin Radu on 27/12/2021.
//

import Foundation

struct NewsItem: Identifiable {
    let id: String
    let title: String
    let content: String
}

struct ArticleItem: Identifiable {
    let id: String
    let title: String
    let desc: String
}

class AppState: ObservableObject {
    @Published var news: [NewsItem] = []
    @Published var articles: [ArticleItem] = []
}

extension AppState {
    static var main: AppState = {
        let state = AppState()
        return state
    }()
}
