//
//  File.swift
//
//
//  Created by Valentin Radu on 28/12/2021.
//

import Foundation
import SwiftUI

//public extension NavigationGraph {
//    /// Presents a node. If the segue that leads to it is not marked as `.cover` or `.modal`, all its the siblings will be deactivated.
//    /// The node needs to be reachable (at least one segue must lead to it from one of the current active nodes)
//    /// - parameter node: The node to navigate to
//    /// - seealso: `present(flow:)`
//    /// - seealso: `present(segue:)`
//    func present(node: N) throws {
//        var segues: Set<Segue<N>> = []
//        if pathFlow.isEmpty {
//            for segue in flow.inlets {
//                if segue.out == node {
//                    segues.insert(segue)
//                }
//            }
//        }
//        else {
//            for segue in flow.substract(flow: pathFlow).inlets {
//                if segue.out == node {
//                    segues.insert(segue)
//                }
//            }
//        }
//
//        guard segues.count > 0 else {
//            throw HelmError<N>.inwardIsolated(node: node)
//        }
//
//        guard segues.count == 1 else {
//            throw HelmError<N>.inwardAmbiguous(node: node, segues: segues)
//        }
//
//        let segue = segues.first!
//
//        try present(segue: segue)
//    }
//
//    /// Presents a segue.
//    /// The segue's `in` node needs to be already presented.
//    /// - parameter segue: The segue to navigate to
//    /// - seealso: `present(node:)`
//    /// - seealso: `present(flow:)`
//    func present(segue: Segue<N>) throws {
//        guard !pathFlow.has(segue: segue) else {
//            return
//        }
//
//        guard flow.has(segue: segue) else {
//            throw HelmError<N>.missingSegues(value: [segue])
//        }
//
//        let traits = traits[segue] ?? []
//
//        for trait in traits {
//            switch trait {
//            case let .redirected(redirectFlow):
//                if redirectFlow.has(segue: segue) {
//                    throw HelmError<N>.circularRedirection(segue: segue)
//                }
//                try present(flow: redirectFlow)
//                return
//            default:
//                break
//            }
//        }
//
//        if !traits.contains(.context) {
//            pathFlow = pathFlow.trim(at: segue.in)
//        }
//
//        pathFlow = pathFlow.add(segue: segue)
//
//        var autoSegues: Set<Segue<N>> = []
//        for segue in flow.egressSegues(for: segue.out) {
//            let traits = self.traits[segue] ?? []
//            if traits.contains(.auto) {
//                autoSegues.insert(segue)
//            }
//        }
//
//        guard autoSegues.count < 2 else {
//            throw HelmError<N>.multiAuto(node: segue.out, segues: autoSegues)
//        }
//
//        if let segue = autoSegues.first {
//            try present(segue: segue)
//        }
//    }
//
//    /// Presents an entire flow.
//    /// The flow needs to have one single inlet (a single node that has only outward segues and no inward segues). Also, this inlet needs to be already presented.
//    /// - parameter flow: The flow to navigate to
//    /// - seealso: `present(node:)`
//    /// - seealso: `present(segue:)`
//    func present(flow: Flow<N>) throws {
//        guard flow.inlets.count > 0 else {
//            throw HelmError<N>.noInletFlow
//        }
//
//        guard flow.inlets.count == 1 else {
//            throw HelmError<N>.multiInletFlow(from: Set(flow.inlets.map { $0.in }))
//        }
//
//        for segue in flow.segues {
//            try present(node: segue.out)
//        }
//    }
//
//    /// Looks at the most recently presented segue and tries to navigate any egress segue from its `out` node to a node that is not yet presented. Note that there might be multiple such segues, or none, in which case `forward()` does nothing.
//    func forward() throws {
//        var segues: Set<Segue<N>> = []
//        let startNode: N
//
//        if let last = pathFlow.segues.last?.out {
//            startNode = last
//        }
//        else {
//            let entries = Set(flow.inlets.map { $0.in })
//
//            guard entries.count > 0 else {
//                throw HelmError<N>.noInletFlow
//            }
//
//            guard entries.count == 1 else {
//                throw HelmError<N>.multiInletFlow(from: entries)
//            }
//
//            startNode = try entries.first.unwrap()
//        }
//
//        segues = flow.egressSegues(for: startNode)
//
//        guard segues.count > 0 else {
//            throw HelmError.inwardIsolated(node: startNode)
//        }
//
//        guard segues.count == 1 else {
//            throw HelmError.inwardAmbiguous(node: startNode, segues: segues)
//        }
//
//        try present(segue: segues.first.unwrap())
//    }
//
//    /// Looks at the most recently presented segue and tries to navigate using its counterpart. Note that there might be no such a segue counterpart, in which case `back()` throws an error.
//    func dismiss() throws {
//        guard let last = pathFlow.segues.last else {
//            throw HelmError<N>.nothingPresented
//        }
//
//        try dismiss(segue: last)
//    }
//    
//    /// Looks for the first context presented and dismisses it.
//    func dismissContext() throws {
//        guard let last = pathFlow.segues.last else {
//            throw HelmError<N>.nothingPresented
//        }
//        
//        let segue = pathFlow.segues.first {
//            traits[$0]?.contains(.context) == true
//        }
//        
//        guard let segue = segue else {
//            throw HelmError<N>.noContext(from: last.out)
//        }
//        
//        try dismiss(segue: segue)
//    }
//
//    /// Attempts to reach a node navigating using only reverse segues relative to the ones already presented.
//    func dismiss(node: N) throws {
//        let segues = pathFlow.ingressSegues(for: node)
//
//        guard segues.count > 0 else {
//            throw HelmError<N>.inwardIsolated(node: node)
//        }
//
//        guard segues.count == 1 else {
//            throw HelmError<N>.inwardAmbiguous(node: node, segues: segues)
//        }
//
//        try dismiss(segue: segues.first.unwrap())
//    }
//
//    func dismiss(segue: Segue<N>) throws {
//        guard flow.has(segue: segue.counterpart) else {
//            throw HelmError<N>.cantFindaSegueCounterpart(segue: segue)
//        }
//
//        pathFlow = pathFlow.trim(at: segue.counterpart.out)
//    }
//
//    /// Checks if a node is presented (active)
//    /// - returns: True if the node is active
//    func isPresented(_ node: N) -> Bool {
//        if flow.segues.first?.in == node {
//            return true
//        }
//        return pathFlow.has(node: node)
//    }
//
//    /// A special `isPresented(node:)` function that returns a binding.
//    /// When the value is set to false from the binding, the node becomes inactive, trimming all the nodes that originate from it as well.
//    func isPresented(_ node: N) -> Binding<Bool> {
//        return Binding {
//            self.isPresented(node)
//        } set: { [self] in
//            do {
//                if $0 {
//                    try present(node: node)
//                }
//                else {
//                    try dismiss(node: node)
//                }
//            }
//            catch {
//                assertionFailure(error.localizedDescription)
//            }
//        }
//    }
//}
