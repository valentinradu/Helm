// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

func forwardEnvsToSwiftSettings(_ value: String...) -> [SwiftSetting] {
    value.compactMap {
        if ProcessInfo.processInfo.environment[$0] != nil {
            return SwiftSetting.define($0)
        }
        return nil
    }
}

let package = Package(
    name: "Helm",
    platforms: [
        .iOS(.v14), .macOS(.v11), .tvOS(.v9),
        .macCatalyst(.v13), .watchOS(.v2), .driverKit(.v19)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Helm",
            targets: ["Helm"]),
        .library(
            name: "Playground",
            targets: ["Playground"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Helm",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            swiftSettings: forwardEnvsToSwiftSettings("HELM_DISABLE_ASSERTIONS")),
        .target(
            name: "Playground",
            dependencies: ["Helm"],
            resources: [.process("Media.xcassets")]),
        .testTarget(
            name: "HelmTests",
            dependencies: ["Helm"])
    ])
