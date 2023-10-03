// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "appcastgen",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "appcastgen", targets: ["appcastgen"]),
        .library(name: "Appcast", targets: ["Appcast"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/mflint/Ink.git", branch: "multiple-depth-list-parsing")
    ],
    targets: [
        .executableTarget(
            name: "appcastgen",
            dependencies: [
                "Appcast",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "Appcast",
            dependencies: [
                .product(name: "Ink", package: "Ink"),
            ]
        ),
        .testTarget(name: "AppcastTests", dependencies: ["Appcast"]),
    ]
)
