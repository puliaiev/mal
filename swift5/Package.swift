// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mal",
    products: [
        .executable(name: "step0_repl", targets: ["step0_repl"]),
        .executable(name: "step1_read_print", targets: ["step1_read_print"]),
        .executable(name: "step2_eval", targets: ["step2_eval"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "step0_repl", dependencies: []),
        .target(name: "step1_read_print", dependencies: ["MalCore"]),
        .target(name: "step2_eval", dependencies: ["MalCore"]),
        .target(name: "MalCore", dependencies: []),
    ],
    swiftLanguageVersions: [.v5]
)
