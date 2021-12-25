//
//  SwiftUIView.swift
//
//
//  Created by Valentin Radu on 04/12/2021.
//

import SwiftUI

//public protocol FragmentIdentifier {}
//public protocol FragmentMatcher {
//    associatedtype R
//    associatedtype I: FragmentIdentifier
//    func match(id: I) -> FragmentMatcherResult<R>
//}
//
//public enum FragmentMatcherResult<R> {
//    case miss
//    case match(R)
//}
//
//public extension EnvironmentValues {
//    var fragment: FragmentIdentifier {
//        get { self[FragmentIdentifierKey.self] }
//        set { self[FragmentIdentifierKey.self] = newValue }
//    }
//}
//
//public struct RouteMatcher: FragmentMatcher {
//    private let glob: String
//    public init(_ glob: String) {
//        self.glob = glob
//    }
//
//    public func match(id: String) -> FragmentMatcherResult<Void> {
//        .match(())
//    }
//}
//
//public struct RouteMatcher1: FragmentMatcher {
//    private let glob: String
//    public init(_ glob: String) {
//        self.glob = glob
//    }
//
//    public func match(id: String) -> FragmentMatcherResult<String> {
//        .match(id)
//    }
//}
//
//public struct RouteMatcher2: FragmentMatcher {
//    private let glob: String
//    public init(_ glob: String) {
//        self.glob = glob
//    }
//
//    public func match(id: String) -> FragmentMatcherResult<(String, String)> {
//        .match((id, id))
//    }
//}
//
//public extension FragmentMatcher {
//    static func route(_ glob: String) -> RouteMatcher { .init(glob) }
//    static func route1(_ glob: String) -> RouteMatcher1 { .init(glob) }
//    static func route2(_ glob: String) -> RouteMatcher2 { .init(glob) }
//}
//
//private struct DefaultFragmentIdentifier: FragmentIdentifier {}
//
//private struct FragmentIdentifierKey: EnvironmentKey {
//    static let defaultValue: FragmentIdentifier = DefaultFragmentIdentifier()
//}
//
//public struct Fragment<M: FragmentMatcher, V: View>: View {
//    @Environment(\.fragment) private var fragment
//    private let content: (M.R) -> AnyView
//    private let matcher: M
//    public init(_ matcher: M, @ViewBuilder content: @escaping () -> V) {
//        self.matcher = matcher
//        self.content = { _ in AnyView(content()) }
//    }
//
//    public init<D>(_ matcher: M, @ViewBuilder content: @escaping (D) -> V) {
//        self.matcher = matcher
//        self.content = {
//            if let data = $0 as? D {
//                return AnyView(content(data))
//            }
//            else {
//                assertionFailure("Fragment data type mismatch for \(type(of: matcher)). Expected \(D.self), got \(type(of: $0))")
//                return AnyView(EmptyView())
//            }
//        }
//    }
//
//    public var body: some View {
//        let result = matcher.match(id: fragment)
//        switch result {
//        case .miss:
//            return AnyView(EmptyView())
//        case let .match(value):
//            return AnyView(content(value))
//        }
//    }
//}
//
//#if DEBUG
//struct Article {
//    let id: String
//    let name: String
//}
//
//struct Fragment_Previews: PreviewProvider {
//    struct Preview: View {
//        @State var fragment: String = .root
//        var body: some View {
//            VStack {
//                Group {
//                    Fragment(.route("/home")) {
//                        Text(fragment)
//                    }
//                    Fragment(.route1("/home/articles/1")) { (article: Article) in
//                        Text(article.name)
//                    }
//                }
//                .environment(\.fragment, fragment)
//                HStack {
//                    Button(action: { fragment = .root }) {
//                        Text("Root")
//                    }
//                    Button(action: { fragment = .article }) {
//                        Text("Article")
//                    }
//                }
//            }
//        }
//    }
//
//    static var previews: some View {
//        Preview()
//    }
//}
//
//extension String: FragmentIdentifier {}
//
//#endif
