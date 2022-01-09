//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation
import SwiftUI

private extension DirectedGraph {
    func presentedSections<S: Section>(for _: GraphPath<DirectedEdge<S>>) -> GraphPath<DirectedEdge<S>> where S == Element.N {
        []
    }
}

/// `Helm` holds all navigation rules between sections in the app, plus the path that leads to the currently presented ones.
public class Helm<S: Section>: ObservableObject {
    /// The graph that describes all the navigation rules in the app.
    public let nav: DirectedGraph<Segue<S>>

    /// The currently presented sections and the relationship between them.
    public private(set) var path: GraphPath<DirectedEdge<S>> {
        didSet {
            presentedSections = nav.presentedSections(for: path)
        }
    }

    /// The presented sections in the order they were presented.
    @Published public private(set) var presentedSections: GraphPath<DirectedEdge<S>>

    /// All the errors triggered by navigating
    @Published public private(set) var errors: [Error]

    /// Initializes a new Helm instance.
    /// - parameter nav: A directed graph of segues that defies all the navigation rules between sections in the app.
    /// - parameter path: The path that leads to the currently presented sections.
    public init(nav: DirectedGraph<Segue<S>>,
                path: GraphPath<DirectedEdge<S>> = []) throws
    {
        errors = []
        presentedSections = nav.presentedSections(for: path)
        self.nav = nav
        self.path = path
        try validate()
    }

    public func present(_ query: SegueQuery<S>? = nil) {}

    public func dimiss(_ query: SegueQuery<S>? = nil) {}

    /// Checks if a section is presented. Shorthand for `presentedSections.contains(section)`
    /// - returns: True if the section is presented.
    public func isPresented(_ section: S) -> Bool {
        return presentedSections.has(node: section)
    }

    /// A special `isPresented(section:)` function that returns a binding.
    /// Setting the value to false from the binding is the same thing as calling `dismiss(section:)` with the section as the parameter
    /// - parameter section: The section
    /// - returns: A binding, true if the section is presented.
    public func isPresented(_ section: S) -> Binding<Bool> {
        return Binding {
            self.isPresented(section)
        } set: {
            if $0 {
                self.present(.section(section))
            } else {
                self.dimiss(.section(section))
            }
        }
    }

    private func validate() throws {
        if nav.isEmpty {
            throw HelmError<S>.emptyNav
        }

        if nav.inlets.count == 0 {
            throw HelmError<S>.noNavInlets
        }

        if let segues = nav.filter({ $0.auto }).firstCycle {
            throw HelmError<S>.autoCycleDetected(segues: segues)
        }
    }
}
