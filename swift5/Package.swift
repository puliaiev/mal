// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mal",
    products: [
        .executable(name: "step0_repl", targets: ["step0_repl"])
    ],
    dependencies: [],
    targets: [
        .target(name: "step0_repl", dependencies: [])
    ],
    swiftLanguageVersions: [.v5]
)
