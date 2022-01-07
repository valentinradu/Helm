//
//  File.swift
//
//
//  Created by Valentin Radu on 10/12/2021.
//

import Foundation
import SwiftUI

/// `Helm` holds all navigation rules between sections in the app, plus the path that leads to the currently presented ones.
public class Helm<S: Section>: ObservableObject {
    let rules: DirectedGraph<Segue<S>>

    /// The currently presented sections and the relationship between them.
    @Published public var path: GraphPath<DirectedEdge<S>>

    /// Initializes a new Helm instance.
    /// - parameter rules: A directed graph of segues that defies all the navigation rules between sections in the app.
    /// - parameter path: The path that leads to the currently presented sections.
    public init(rules: DirectedGraph<Segue<S>>,
                path: GraphPath<DirectedEdge<S>> = []) throws
    {
        self.rules = rules
        self.path = path
    }

    /// Presents one or multiple sections. The first section has to be connected by an egress segue from an already presented section. Also, the presented sections need to be all connected to each other in the rules graph.
    /// - parameter section: The section(s) to present
    public func present(_ section: S) throws {}

    /// Dismisses a specific section. This action might also dismiss other sections if they have no other ingress segues but the one originating from this section.
    /// - parameter section: The section to dismiss
    public func dimiss(_ section: S) throws {}

    /// Dismisses the last presented section
    /// - seealso: `dismiss(section:)`
    public func dimiss() throws {}

    /// All the sections that are curently presented.
    public var presentedSections: Set<S> { [] }

    /// Checks if a section is presented. Shorthand for `presentedSections.contains(section)`
    /// - returns: True if the section is presented.
    public func isPresented(_ section: S) -> Bool {
        return presentedSections.contains(section)
    }

    /// A special `isPresented(section:)` function that returns a binding.
    /// Setting the value to false from the binding is the same thing as calling `dismiss(section:)` with the section as the parameter
    /// - parameter section: The section
    /// - returns: A binding, true if the section is presented.
    public func isPresented(_ section: S) -> Binding<Bool> {
        return Binding {
            self.isPresented(section)
        } set: {
            do {
                if $0 {
                    try self.present(section)
                }
                else {
                    try self.dimiss(section)
                }
            }
            catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
