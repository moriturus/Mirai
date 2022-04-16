// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Mirai",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Mirai",
            targets: ["Mirai"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Mirai",
            dependencies: []),
        .testTarget(
            name: "MiraiTests",
            dependencies: ["Mirai"]),
    ])
